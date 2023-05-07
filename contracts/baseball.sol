// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 게임 매니저 컨트랙트
contract GameManager {
    // game contract address list
    address[] public games;
    NumberBaseball public game;

    constructor() {
        // deploy new game contract
        games.push(address(new NumberBaseball(address(this))));
    }

    function getGameAddress() public view returns (address) {
        return games[games.length - 1];
    }

    function getGameHistory() public view returns (address[] memory) {
        return games;
    }

    function onGameEnded() external {
        require(
            msg.sender == address(games[games.length - 1]),
            "Only game contract can call this function"
        );

        // deploy new game contract
        games.push(address(new NumberBaseball(address(this))));

        // subscribe to game events
        address gameAddress = getGameAddress();
        game = NumberBaseball(payable(gameAddress));
    }
}

contract NumberBaseball {
    address private managerAddress; // 게임 매니저의 주소

    uint public constant MAX_PLAYERS = 2; // 최대 참가자 수
    uint public constant JOIN_FEE = 1 ether; // 참가비
    uint public constant PLAY_FEE = 0.1 ether; // 맞추기 시도 비용

    uint public numPlayers; // 참가자 수
    uint public currentTurn; // 현재 차례
    uint public turnTimedoutTimestamp; // 턴 종료 시간
    uint public winningNumber; // 정답 숫자
    uint public winningAmount; // 이긴 사람이 가져갈 금액
    address payable public winner; // 이긴 사람의 주소

    mapping(uint => address payable) public players; // 참가자 목록
    mapping(address => uint) public playerGuesses; // 참가자의 추측 숫자
    mapping(address => uint) public playerAmounts; // 참가자가 지불한 금액
    mapping(address => bool) public playerPlayed; // 참가자가 이미 맞추기를 시도했는지 여부
    mapping(address => bool) public playerWithdrawn; // 참가자가 보상을 이미 인출했는지 여부
    mapping(address => uint) public playerLastAction; // 참가자의 마지막 동작 시간

    event GameStarted();
    event TurnStarted(address player);
    event GuessResult(
        address player,
        uint guess,
        uint numStrikes,
        uint numBalls
    );
    event GameEnded(address winner, uint winningNumber, uint winningAmount);
    event TurnTimedOut(address player);

    constructor(address _managerAddress) {
        managerAddress = _managerAddress;
    }

    // 게임에 참가하기 위한 함수
    function joinGame() public payable {
        require(numPlayers < MAX_PLAYERS, "Maximum number of players reached");
        require(msg.value >= JOIN_FEE, "Insufficient amount to join the game");
        require(
            playerAmounts[msg.sender] == 0,
            "You have already joined the game"
        );

        players[numPlayers] = payable(msg.sender);
        playerAmounts[msg.sender] = msg.value;
        numPlayers++;
        winningAmount += msg.value;

        if (numPlayers == MAX_PLAYERS) {
            startGame();
        }
    }

    // 게임 시작 함수
    function startGame() private {
        require(
            numPlayers == MAX_PLAYERS,
            "Not enough players to start the game"
        );

        // 랜덤한 3자리 숫자 생성
        uint seed = 0;
        do {
            seed++;
            winningNumber =
                (uint(
                    keccak256(
                        abi.encodePacked(
                            block.timestamp,
                            block.prevrandao,
                            seed
                        )
                    )
                ) % 900) +
                100;
        } while (
            winningNumber % 10 == (winningNumber / 10) % 10 ||
                winningNumber % 10 == winningNumber / 100 ||
                (winningNumber / 10) % 10 == winningNumber / 100
        );

        emit GameStarted();

        // 첫 번째 참가자부터 시작
        currentTurn = 0;
        startTurn();
    }

    // 차례 시작 함수
    function startTurn() private {
        address player = players[currentTurn];
        playerLastAction[player] = block.timestamp;

        emit TurnStarted(player);
    }

    // 맞추기 시도 함수
    function play(uint guess) public payable {
        uint first_digit = guess / 100;
        uint second_digit = (guess / 10) % 10;
        uint third_digit = guess % 10;

        require(currentTurn < numPlayers, "Game is not in progress");
        require(msg.sender == players[currentTurn], "It's not your turn");
        require(msg.value >= PLAY_FEE, "Insufficient amount to play the game");
        require(guess >= 100 && guess <= 999, "Invalid guess");
        require(
            first_digit != second_digit &&
                second_digit != third_digit &&
                third_digit != first_digit,
            "All digits must be different"
        );

        // 상금 증가
        winningAmount += msg.value;

        // 숫자 비교
        (uint numStrikes, uint numBalls) = compareNumbers(guess, winningNumber);

        // 결과 저장
        playerGuesses[msg.sender] = guess;
        playerPlayed[msg.sender] = true;

        // 스트라이크가 3개면 게임 종료
        if (numStrikes == 3) {
            winner = payable(msg.sender);
            endGame();
            return;
        } else {
            // 스트라이크가 3개가 아니면 추측 결과 반환
            emit GuessResult(msg.sender, guess, numStrikes, numBalls);
        }

        // 다음 차례로 넘어가기
        currentTurn++;
        if (currentTurn == numPlayers) {
            currentTurn = 0;
        }
        startTurn();
    }

    // 숫자 비교 함수
    function compareNumbers(
        uint guess,
        uint answer
    ) private pure returns (uint numStrikesResult, uint numBallsResult) {
        uint guessDigit;
        uint answerDigit;

        for (uint i = 0; i < 3; i++) {
            guessDigit = (guess / (10 ** i)) % 10;
            answerDigit = (answer / (10 ** i)) % 10;

            if (guessDigit == answerDigit) {
                numStrikesResult++;
            } else if (
                // 스트라이크가 아니면서 숫자가 겹치는 경우
                guessDigit == ((answer / (10 ** ((i + 1) % 3))) % 10) ||
                guessDigit == ((answer / (10 ** ((i + 2) % 3))) % 10)
            ) {
                numBallsResult++;
            }
        }
    }

    // 게임 종료 함수
    function endGame() private {
        // 이긴 사람에게 보상 지급
        winningAmount = address(this).balance;
        if (!winner.send(winningAmount)) {
            revert("Failed to send ether to the winner");
        }

        emit GameEnded(winner, winningNumber, winningAmount);

        // 게임 매니저에게 게임 종료 알림
        GameManager(managerAddress).onGameEnded();
    }

    // 이긴 사람인지 여부 반환 함수
    function isWinner(address player) public view returns (bool) {
        return player == winner;
    }

    // 스마트 컨트랙트에 남아있는 금액을 승자에게 전송하는 함수
    function withdraw() public {
        require(isWinner(msg.sender), "You are not the winner");
        require(
            !playerWithdrawn[msg.sender],
            "You have already withdrawn your prize"
        );

        playerWithdrawn[msg.sender] = true;

        // send current balance to the winner
        if (!winner.send(address(this).balance)) {
            revert("Failed to send ether to the winner");
        }
    }

    // 스마트 컨트랙트에 전송된 ether를 반환하는 함수
    receive() external payable {}
}
