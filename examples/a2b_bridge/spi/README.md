# A2B Bridge as SPI Tunnel Owner on Main Node

1) The Main node must be connected to the processor node via I2C not SPI.
The A2B Bridge does not currently support SPI for discovery.

2) When using A2B Plugin 19.11.1, one must manually set the Main node
SPI_CFG.SPIMODE register bits to 0x00 (SPI Slave Mode).

Review the Sigma Studio project included in this folder for details.