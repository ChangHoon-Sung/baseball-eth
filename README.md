# Ethereum 블록체인 기반 숫자 야구 게임

이 프로젝트는 이더리움 로컬 블록체인 Ganache와 스마트 컨트랙드 개발도구 Truffle을 사용하여 만든 턴제 숫자 야구 게임입니다.

이 게임은 Solidity로 작성된 스마트 컨트랙트를 사용하여 동작하며, Web3.js를 사용하여 웹 페이지와 상호작용합니다.

## 시작하기

### 사전 준비
- [Node.js](https://nodejs.org/ko/) 설치
- [Metamask](https://metamask.io/) 설치 (Chrome only)

### 로컬 실행 방법

1. 프로젝트 클론
    ```
    git clone
    ```
2. 의존성 패키지 설치
    ```
    npm install
    ```
3. Ganache 실행
    ```
    ganache ---wallet.seed 2
    ```
4. 다른 터미널에서 Truffle 컴파일 및 마이그레이션 
    ```
    truffle migrate 
    ```
    > 이때 `1_init.js`의 creatorAddress 값은 wallet.seed == 2로 생성한 랜덤 계정 중 1번째로 하드코딩 되어있으며, 필요 시 Ganache 터미널에서 확인한 임의의 계정 주소 또는 블록체인 네트워크 내에 존재하는 계정 주소로 변경할 수 있음)

5. Ganache 터미널을 확인하여 임의의 계정 비밀키를 Metamask 월렛에 추가(import)
6. MetaMask에 네트워크 추가
    ```
    Network Name: Ganache
    New RPC URL: http://localhost:8545
    Chain ID: 1337
    Currency Symbol: ETH
    ```
7. 웹 서버 실행
    ```
    serve -s
    ```
8. 웹 브라우저에서 http://localhost:3000 접속
9. Connect Wallet 버튼을 눌러 Metamask 월렛을 연결
10.   https://github.com/ChangHoon-Sung/baseball-eth/blob/1c4fa48acf29b0cd4826895f61c2f2a5b8111eec/contracts/baseball.sol#L41 참조하여 MAX_PLAYERS만큼 월렛 연결 (Chrome에서 새 프로필을 추가하여 여러 월렛을 연결할 수 있음)
11.  게임 진행!

## 게임 규칙
- 이 게임은 3자리 숫자를 맞추는 게임입니다.
- 게임에 참가하려면 1 이더를 지불해야 합니다.
- 게임에 참가한 후, 차례가 되면 0.1 이더를 지불하고 3자리 숫자를 추측합니다.
- 추측한 숫자가 정답과 일치하지 않을 경우, 스트라이크와 볼 수를 받게 됩니다.
- 3 스트라이크를 받으면 게임에서 이기게 됩니다.
- 게임이 끝나면 이긴 사람은 상금을 가져갈 수 있습니다.

## 활용 기술
- Ganache: 로컬 블록체인 네트워크
- Truffle: Solidity 스마트 컨트랙트를 개발 및 배포 프레임워크
- Solidity: 이더리움 블록체인에서 스마트 컨트랙트를 작성 시 사용한 언어
- Web3.js: 이더리움 블록체인과 상호작용하는 JavaScript 라이브러리
- Metamask: 이더리움 지갑 (Metamask를 사용하여 월렛을 블록체인과 연결함)

## License
MIT License (see [LICENSE.md](LICENSE.md))
