# Verification-of-Single-PORT-RAM-using-UVM
This project aims to verify the design of a single port RAM using UVM 
This project provides a UVM verification environment for a single port RAM. The environment is designed to be comprehensive and to test all aspects of the RAM's design, including its functionality, performance, and error handling capabilities.

Components

The verification environment consists of the following components:

Mo_driver: This component transfer random inputs to the RAM through the virtual interface and asserts them on the RAM's input ports.
Mo_monitor: This component captures the RAM's output data and transfer it to the scorboard and subscriber.
Mo_sequencer: This component controls the order in which the driver and monitor components are activated as it represents the CU.
Mo_scoreboard: This component compares the expected and actual outputs of the RAM by running a checking mechanism and reports any errors.
Mo_subscriber: This component produces the coverage report based on the coverpoints convered.
Constraints

The verification environment uses constraints to randomize the values of the RAM inputs. This helps to ensure that the tests are comprehensive and that all possible input values are tested.
