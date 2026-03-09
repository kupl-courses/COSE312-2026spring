# COSE312 - Compilers, 2026 Spring

## 실습 환경 설정

### 1. _Docker_ 설치
https://www.docker.com/

설치 확인: 터미널에서 `docker --version` 실행 (버전은 달라도 됨)
```console
ta@cose312:~$ docker --version
Docker version 27.5.1, build 9f9e405
```

### 2. _Visual Studio Code_ (VSC) 설치
https://code.visualstudio.com/

### 3. VSC Extension _Dev Containers_ 설치
![dev_containers](https://github.com/user-attachments/assets/c5b807b3-5a30-48b6-8efc-73c58f142859)

### 4. _Dev containers_ 실행
1. Clone this repository
    ```console
    ta@cose312:~$ git clone https://github.com/kupl-courses/COSE312.git
    ```
    (필요시 git 설치: https://git-scm.com/downloads)

2. Open in VSC
    ```console
    ta@cose312:~$ code COSE312
    ```

3. 우측 하단 메세지 내 좌측 버튼 _Reopen in Container_ 클릭
    ![vsc_reopen_in_container-1](https://github.com/user-attachments/assets/48d7f30c-834d-4ace-81ba-a02b459173dc)

    위 메세지가 없으면 좌측 최하단 버튼 _Open a Remote Window_ 클릭 후 _Reopen in Container_ 클릭
    ![vsc_reopen_in_container-2](https://github.com/user-attachments/assets/fe8692a2-34a9-40a5-ac4f-518236da96a9)

## 코드 실행

### REPL 사용
VSC 터미널에서 `ocaml` 실행
```console
$ ocaml
```

Tip. 현재 디렉토리에 `.ocamlinit` 파일 생성 후 `#use "<파일명>.ml"`을 작성하면 REPL 실행시에 해당 파일을 자동으로 불러옴

### .ml 파일 컴파일 및 실행 (;;로 구분 필요 없음)
VSC 터미널에서 `ocamlc -o <실행파일명> <파일명>.ml` 또는 `ocamlopt -o <실행파일명> <파일명>.ml` 실행
```console
$ ocamlopt -o main main.ml
$ ./main
```

### OCaml 스크립트 실행 (;;로 구분 필요)
VSC 터미널에서 `ocaml <파일명>.ml` 또는 `ocaml < <파일명>.ml` 실행
```console
$ ocaml < src/main.ml
```

## 업데이트된 과제 템플릿 다운로드
COSE312 디렉토리에서 `git pull` 실행
```console
$ pwd
/workspace/COSE312
$ git pull
```