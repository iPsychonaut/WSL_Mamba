# WSL2 + Ubuntu + Conda + Mamba Setup

## Step 1: Installation1.ps1
Open PowerShell as Administrator and run:

    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    .\Installation1.ps1

This enables required Windows features, updates WSL, and sets WSL2 as default.  
Reboot your computer when prompted.

## Step 2: Installation2.ps1
After reboot, open PowerShell (Admin not required) and run:

    .\Installation2.ps1

This installs Ubuntu, updates it, installs Miniforge (Conda), and Mamba.  
When the Ubuntu window launches, create your Linux username and password, then close the window and press Enter in PowerShell to continue.

## Notes
- After installation, you can start Ubuntu from the Start Menu.
- Conda is installed in ~/miniforge3.
- Mamba is installed in the base environment.
- To activate conda in Ubuntu:

    conda activate base

- A test environment with Python and NumPy will be created automatically to confirm the setup works.
