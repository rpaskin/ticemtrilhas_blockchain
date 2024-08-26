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

    struct RegistroSocial {
        string  perfil;         // nome do perfil que estamos salvando
        uint256 quando_criado;  // quando o registro foi criado
    }

    // RegistroSocial public registro;
    mapping(address => RegistroSocial) public registros;

    uint256 public preco;       // preco em wei para salvar nesse contrato
    address public criador;     // criador do contrato
    uint256 public count;       // quantidade total de registros

    // Evento para ser emitido quando o perfil é guardado
    event Guardado(string _perfil, address _dono);

    /**
     * @dev Armazena o preco e criador para usar o contrato
     */
    constructor(uint256 _preco) {
        preco = _preco;
        criador = msg.sender;
    }
    
    /**
     * @dev Permite salvar um nome de perfil associado a um endereco de carteira. Requer que seja enviado o valor definido no construtor do contrato.
     * @param _perfil String representando o nome do perfil a ser salvo.
     * @param _dono Endereco da carteira do dono do perfil.
     */
    function guardar(string calldata _perfil, address _dono) public payable {
        require(registros[_dono].quando_criado == 0, "Um perfil ja esta guardado para este dono!");
        require(msg.value >= preco, "Precisa receber o valor correto!");

        envia_troco();
        envia_pagamento();

        registros[_dono].perfil = _perfil;
        registros[_dono].quando_criado = block.timestamp;

        count++;

        emit Guardado(_perfil, _dono);

        emitir_token();
    }

    /**
    * @dev Envia troco para o dono do perfil, se necessário. 
    */     
    function envia_troco() private {
        uint256 valor = preco - msg.value;

        if (valor > 0){
            payable(msg.sender).transfer(valor);
        }
    } 
      
    /**
    * @dev Envia o saldo restante do contrato para o criador
    */
    function envia_pagamento() private {
        // envia o resto do saldo do contrato para o criador
        payable(criador).transfer(address(this).balance);
    }

    function emitir_token() private {
        // emitir token para msg.sender
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
        if (registros[_dono].quando_criado == 0){
            return 0;
        }
        else {
            return 1;
        }
    }

    function allowance(address, address) external pure returns (uint remaining){
        // Returns the amount which _spender is still allowed to withdraw from _owner.
        return 0;
    }

    function transfer(address, uint) external pure returns (bool _sucesso){
        // Transfere a quantidade _valor de tokens para o endereço _para, e DEVE disparar o evento Transfer. A função DEVE lançar uma exceção se o saldo da conta do chamador da mensagem não tiver tokens suficientes para gastar.
        return false;
    }

    function approve(address, uint) external pure returns (bool _sucesso){
        // Permite que _gastador saque da sua conta várias vezes, até a quantidade _valor. Se esta função for chamada novamente, ela sobrescreve a permissão atual com _valor.
        return false;
    }

    function transferFrom(address, address, uint) external pure returns (bool _sucesso){
        // Transfere a quantidade _valor de tokens do endereço _de para o endereço _para, e DEVE disparar o evento Transfer.
        return false;
    }
}

