# How to install Jupyter Notebooks and .NET Interactive

## Windows (TBC)

## WSL (Ubuntu 20.04)

1. Install the Python package manager ```pip```

    ```bash
    sudo apt install python3-pip
    ```

2. Install Jupyter notebooks

    ```bash
    pip3 install notebook
    ```

3. Verify jupyter has been installed

    ```bash
    jupyter kernelspec list
    ```

    Should display similar:

    ```bash
    Available kernels:
      python3                                           /home/user/.local/share/jupyter/kernels/python3
      python38264bit135cd25197314bc588989d783b05050d    /home/user/.local/share/jupyter/kernels/python38264bit135cd25197314bc588989d783b05050d
    ```

4. Add Microsoft repository key and feed

    ```bash
    wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    ```

5. Install .NET Core SDK and runtime

    ```bash
    sudo apt-get update
    sudo apt-get install apt-transport-https
    sudo apt-get update
    sudo apt-get install dotnet-sdk-3.1 dotnet-runtime-3.1
    ```

6. Install dotnet interactive

    ```bash
    dotnet tool update -g Microsoft.dotnet-interactive --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"
    ```

7. Install dotnet interactive Jupyter kernels

    ```bash
    dotnet interactive jupyter install
    ```

    Verify installation

    ```bash
    jupyter kernelspec list
    ```

    Should now display:

    ```bash
    Available kernels:
      .net-csharp                                       /home/user/.local/share/jupyter/kernels/.net-csharp
      .net-fsharp                                       /home/user/.local/share/jupyter/kernels/.net-fsharp
      .net-powershell                                   /home/user/.local/share/jupyter/kernels/.net-powershell
      python3                                           /home/user/.local/share/jupyter/kernels/python3
      python38264bit135cd25197314bc588989d783b05050d    /home/user/.local/share/jupyter/kernels/python38264bit135cd25197314bc588989d783b05050d
    ```

8. Start jupyter notebook

    ```bash
    cd
    git clone https://github.com/Azure/Enterprise-Scale.git
    cd Enterprise-Scale/demo
    jupyter notebook &
    ```

    Make a note of the server URL in the output and navigate using your browser in Windows

    ```bash
    [I 11:51:20.798 NotebookApp] Serving notebooks from local directory: /home/user/Enterprise-Scale/demo
    [I 11:51:20.798 NotebookApp] The Jupyter Notebook is running at:
    [I 11:51:20.799 NotebookApp] http://localhost:8888/?token=3a96245be09fdb7cf0f9ca8f2aa862b99b5b51554b2e6e00
    [I 11:51:20.799 NotebookApp]  or http://127.0.0.1:8888/?token=3a96245be09fdb7cf0f9ca8f2aa862b99b5b51554b2e6e00
    [I 11:51:20.799 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
    [C 11:51:21.013 NotebookApp]

        To access the notebook, open this file in a browser:
            file:///home/user/.local/share/jupyter/runtime/nbserver-18325-open.html
        Or copy and paste one of these URLs:
            http://localhost:8888/?token=3a96245be09fdb7cf0f9ca8f2aa862b99b5b51554b2e6e00
         or http://127.0.0.1:8888/?token=3a96245be09fdb7cf0f9ca8f2aa862b99b5b51554b2e6e00
    ```
