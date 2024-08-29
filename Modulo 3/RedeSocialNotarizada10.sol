// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

interface ERC20Interface {
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract RedeSocialNotarizada is ERC20Interface {
    // event Debug(string, uint);
    // event Debug2(string, address);
    // event Debug3(string, uint, uint, bool);

    struct RegistroSocial {
        string  perfil;         // nome do perfil que estamos salvando
        uint256 quando_criado;  // quando o registro foi criado
    }

    // RegistroSocial public registro;
    mapping(address => RegistroSocial) public registros;

    address[] public detentores_de_tokens;

    mapping(address => uint) public saldo_tokens;

    mapping(address => mapping(address => uint)) public permite_sacar;

    uint256 public  preco;       // preco em wei para salvar nesse contrato
    address public  criador;     // criador do contrato
    uint256 private count;       // quantidade total de registros

    // Evento para ser emitido quando o perfil é guardado
    event Guardado(string _perfil, address _dono);

    modifier apenasCriador {
        require(msg.sender == criador, "Apenas o criador pode fazer isso!");
        _;
    }

    /**
     * @dev Armazena o preco, criador e cria novos tokens para usar o contrato
     */
    constructor() {
        preco = 1;
        criador = msg.sender;
        count = 10000;
        adicionar_detentor(criador);
        saldo_tokens[criador] = count;
    }

    function adicionar_detentor(address _detentor) private {
        if (saldo_tokens[_detentor] == 0){
            detentores_de_tokens.push(_detentor);
        }
    }

    /**
    * @dev Cria novos tokens
    * @param _quantidade Quantidade de tokens criados
    */
    function mint(uint256 _quantidade) public apenasCriador {
        count += _quantidade;
        saldo_tokens[criador] += _quantidade;
    }

    /**
    * @dev Envia tokens para os outros detentores de tokens
    * @param _quantidade Quantidade de tokens a serem enviados
    */
    function airdrop(uint256 _quantidade) public apenasCriador {
        uint tokens_sem_criador = count - saldo_tokens[criador];
        uint proporcao = _quantidade / tokens_sem_criador;

        for (uint i = 0; i < detentores_de_tokens.length; i++) {
            address detentor = detentores_de_tokens[i];

            if (detentor != criador && saldo_tokens[detentor] > 0){
                uint novos_tokens = saldo_tokens[detentor] * proporcao;
                transfer(detentor, novos_tokens);
            }
        }
    }

    /**
     * @dev Permite salvar um nome de perfil associado a um endereco de carteira. Requer que seja enviado o valor definido no construtor do contrato.
     * @param _perfil String representando o nome do perfil a ser salvo.
     * @param _dono Endereco da carteira do dono do perfil.
     */
    function guardar(string calldata _perfil, address _dono) public payable {
        require(registros[_dono].quando_criado == 0, "Um perfil ja esta guardado para este dono!");
        require(saldo_tokens[msg.sender] >= preco, "Precisa ter saldo para pagar!");

        envia_pagamento(msg.sender);

        registros[_dono].perfil = _perfil;
        registros[_dono].quando_criado = block.timestamp;

        count++;

        emit Guardado(_perfil, _dono);
    }
      
    /**
    * @dev Envia o saldo restante do contrato para o criador
    */
    function envia_pagamento(address _de) private {
        transferFrom(_de, criador, preco);
    }

    function name() external pure returns (string memory){
        return "Rede Social Notarizada Token";
    }
    function symbol() external pure returns (string memory){
        return "RSNT";
    }
    function decimals() external pure returns (uint8){
        return 0;
    }

    function totalSupply() external view returns (uint){
        return count;
    }

    function balanceOf(address _dono) external view returns (uint balance){
        return saldo_tokens[_dono];
    }

    // Retorna o quanto o _gastador pode transferir a partir da conta de _dono
    function allowance(address _dono, address _gastador) external view returns (uint _resta){
        return permite_sacar[_dono][_gastador];
    }

    // Transfere a quantidade _quantos de tokens para o endereço _para,
    // e DEVE disparar o evento Transfer.
    // A função DEVE lançar uma exceção se o saldo da conta do
    // chamador da mensagem não tiver tokens suficientes para gastar.
    function transfer(address _para, uint _quantos) public returns (bool _sucesso){
        require(saldo_tokens[msg.sender] >= _quantos, "Nao ha saldo suficiente para transferir!");

        saldo_tokens[msg.sender] -= _quantos;
        adicionar_detentor(_para);
        saldo_tokens[_para]      += _quantos;

        emit Transfer(msg.sender, _para, _quantos);
        return true;
    }

    // Permite que _gastador saque da sua conta várias vezes, até a quantidade _quanto
    // Se esta função for chamada novamente, ela sobrescreve a permissão atual.
    function approve(address _gastador, uint _quanto) external returns (bool _sucesso){
        permite_sacar[msg.sender][_gastador] = _quanto;

        emit Approval(msg.sender, _gastador, _quanto);

        return true;
    }

    // Transfere a quantidade _quantos de tokens do endereço _de para o endereço _para,
    // e DEVE disparar o evento Transfer.
    function transferFrom(address _de, address _para, uint _quantos) public returns (bool _sucesso){
        require(saldo_tokens[_de] >= _quantos, "Nao ha saldo suficiente para transferir!");
        require(permite_sacar[_de][msg.sender] >= _quantos, "Nao tem permissao para retirar!");

        saldo_tokens[_de] = saldo_tokens[_de] - _quantos;
        adicionar_detentor(_para);
        saldo_tokens[_para] = saldo_tokens[_para] + _quantos;

        emit Transfer(_de, _para, _quantos);

        permite_sacar[_de][msg.sender] = permite_sacar[_de][msg.sender] - _quantos;

        return true;
    }
}

