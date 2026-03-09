# COSE312 - Compilers, 2026 Spring

## Environment Setup

### 1. Install _Docker_
https://www.docker.com/

To verify the installation, run `docker --version` in the terminal (the version number may differ).
```console
ta@cose312:~$ docker --version
Docker version 27.5.1, build 9f9e405
```

### 2. Install _Visual Studio Code_ (VSC)
https://code.visualstudio.com/

### 3. Install the VSC Extension _Dev Containers_
![dev_containers](https://github.com/user-attachments/assets/014cba2a-21d6-4244-9863-5ce6359648b5)

### 4. Run _Dev Containers_
1. Clone this repository
    ```console
    ta@cose312:~$ git clone https://github.com/kupl-courses/COSE312.git
    ```
    (If needed, install Git: https://git-scm.com/downloads)

2. Open in VSC
    ```console
    ta@cose312:~$ code COSE312
    ```

3. Click the left button, _Reopen in Container_, in the message shown at the bottom right.
    ![vsc_reopen_in_container-1](https://github.com/user-attachments/assets/4e803a3e-9b0b-4b26-b3eb-fca33b2f99b4)

    If the message does not appear, click the _Open a Remote Window_ button at the bottom left, then click _Reopen in Container_.
    ![vsc_reopen_in_container-2](https://github.com/user-attachments/assets/81dd084e-4106-47f9-8829-8d76ba8e4154)

## Running the Code

### Using the REPL
Run `ocaml` in the VSC terminal.
```console
$ ocaml
```

Tip. If you create a `.ocamlinit` file in the current directory and write `#use "<filename>.ml"` in it, the file will be loaded automatically when the REPL starts.

### Compiling and Running a `.ml` File (`;;` separators are not needed)
Run `ocamlc -o <executable_name> <filename>.ml` or `ocamlopt -o <executable_name> <filename>.ml` in the VSC terminal.
```console
$ ocamlopt -o main main.ml
$ ./main
```

### Running an OCaml Script (`;;` separators are required)
Run `ocaml <filename>.ml` or `ocaml < <filename>.ml` in the VSC terminal.
```console
$ ocaml < src/main.ml
```