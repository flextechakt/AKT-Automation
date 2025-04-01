-- @module scheduler
local scheduler = {}

--[[

Copyright (c) 2015 by Marco Lizza (marco.lizza@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]--

--
-- Any thread's status can be either one of the following values. The typical
-- evolution of a thread can be depicted as follows
--
-- +---------------------------------------------+
-- |                           +--> WAITING --+  |
-- +--> READY -----> RUNNING --+              +--+
--                             +--> SLEEPING -+
--
local READY = 0    -- suspended, will be resumed at the next update
local RUNNING = 1  -- running, only a single thread at once
local WAITING = 2  -- waiting for a named-event to be signalled
local SLEEPING = 3 -- sleeping 'till the timer elapse
local CHECKING = 4 -- held until a give predicate turns true

-- @variable
--
-- This table is indexed with the coroutine handle and holds the waiting
-- parameters for each entry:
-- priority
-- integer value representing thread priority (lower values
-- indicating higher priorities)
-- status
-- any of the above defined values.
-- value
-- signal identifier, timeout value (in milliseconds), or predicate
-- function.
--
local _pool = {}

--
-- @function
--
-- Suspends the calling thread execution. It will be resumed on the next
-- [scheduler.pulse()] call, according the its relative priority.
--
function scheduler.yield(...)
  local thread = coroutine.running()

  local params = _pool[thread]
  params.status = READY
  params.value = nil

  return coroutine.yield(...)
end

--
-- @function
--
-- Suspend the calling thread execution for a give amount of [ticks].
-- Once the timeout is elapsed, the thread will move to [READY] state
-- and will be scheduled in the following [scheduler.pulse()] call.
--
function scheduler.sleep(ticks, ...)
  local thread = coroutine.running()

  local params = _pool[thread]
  params.status = SLEEPING
  params.value = ticks

  return coroutine.yield(...)
end

--
-- @function
--
-- Suspend the calling thread execution until the given [predicate]
-- turns true. Once this happens, the thread will move to [READY] state
-- and will be scheduled in the following [scheduler.pulse()] call.
--
function scheduler.check(predicate, ...)
  local thread = coroutine.running()

  local params = _pool[thread]
  params.status = CHECKING
  params.value = predicate

  return coroutine.yield(...)
end

--
-- @function
--
-- Suspend the calling thread execution until the event with identifier
-- [id] is signalled. See [scheduler.signal()].
--
function scheduler.wait(id, ...)
  local thread = coroutine.running()

  local params = _pool[thread]
  params.status = WAITING
  params.value = id

  return coroutine.yield(...)
end

--
-- @function
--
-- Signals an event given it's identifier-string. The waiting threads are
-- marked as "ready" and will wake on the next [scheduler.pulse()] call.
--
function scheduler.signal(id)
  for _, params in pairs(_pool) do
    if params.status == WAITING then
      if params.value == id then
        -- Signalled threads are not resumed here, but marked as "ready"
        -- and awaken when calling [schedule.pulse()].
        -- This ensure that threads won't be start from within another
        -- thread body but only from a single dispatcher loop. That is,
        -- threads are suspended only from an explicit [sleep()] or
        -- [wait()] call, and not since they are waking up some other
        -- thread.
        -- Note that calling "coroutine.resume()" from a thread yields
        -- and start the called one.
        params.status = READY
        params.value = nil
      end
    end
  end
end

--
-- @function
--
-- Creates a new thread bound to the passed function [procedure]. If passed
-- the [priority] argument indicates the thread priority (higher values
-- means lower priority), otherwise sets it to zero as a default.
-- The thread is initially suspended and will wake up on the next
-- [scheduler.pulse()] call.
--
function scheduler.spawn(procedure, priority, ...)
  local thread = coroutine.create(procedure)

  _pool[thread] = {
    priority = priority or 0, -- if not provided revert to highest
    args = table.pack(...),
    status = READY,
    value = nil
  }

  -- Naïve priority queue implementation, by re-sorting the table every time
  -- we spawn a new thread. A smarter heap-based implementation, at the moment,
  -- it's not worth the effort.
  table.sort(_pool,
    function(lhs, rhs)
      return lhs.priority < rhs.priority
    end)
end

--
-- @function
--
-- Update the thread list considering [ticks] units have passed. Any
-- sleeping thread whose timeout is elapsed will be woken up.
--
function scheduler.pulse(ticks)
  -- First we need to traverse the table, updating the sleeping threads'
  -- timeout and build the list of the ones to be woken up. We are creating
  -- a one-time snapshot in order to be avoid starvation as much as possible.
  local ready_to_resume = {}

  for thread, params in pairs(_pool) do
    -- Dead threads are detected and removed the from the table itself
    -- (and the garbage-collector will eventually handle them).
    local status = coroutine.status(thread)
    if status == "dead" then
      -- Get rid of the not longer alive thread. We are safe in removing the
      -- entry while iterating with [pairs()] since we are setting the
      -- cell to [nil].
      _pool[thread] = nil
    elseif status == "suspended" then
      -- First we need to update the [SLEEPING] threads' timers.
      if params.status == SLEEPING then
        params.value = params.value - ticks
        -- If the timer has elapsed we switch the thread in [READY] state.
        if params.value <= 0 then
          params.status = READY
          params.value = nil
        end
      -- We also try and see if some [CHECKING] threads need to awaken.
      elseif params.status == CHECKING then
        if params.value() then
          params.status = READY
          params.value = nil
        end
      end
      -- If the thread was already in the [READY] state or its timer
      -- just elapsed, queue it in the list.
      if params.status == READY then
          table.insert(ready_to_resume, thread)
      end
    end
  end

  -- Traverse and wake the ready threads, one at a time.
  -- Please note that if a higher priority thread will switch to
  -- ready state as a side-effect of the following loop it won't
  -- be called until the next [scheduler.pulse()] call.
  for _, thread in ipairs(ready_to_resume) do
    local params = _pool[thread]
    params.status = RUNNING
    coroutine.resume(thread, table.unpack(params.args))
  end
end

function scheduler.dump()
  for thread, params in pairs(_pool) do
    print(thread)
    print(string.format("  %d %d %s",
      params.priority, params.status, coroutine.status(thread)))
  end
end

return scheduler
