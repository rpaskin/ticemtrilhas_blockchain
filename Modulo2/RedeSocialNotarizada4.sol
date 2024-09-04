// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

// TODO: modifier apenas_dono para mudar o preco ou cancelar o contrato (perfil falso?)

contract RedeSocialNotarizada {
    string  public perfil;      // nome do perfil que estamos salvando
    address public dono;        // carteira do dono
    uint256 public preco;       // preco em wei para salvar nesse contrato
    address public criador;     // criador do contrato
    bool public utilizado;      // contrato ja foi utilizado?

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
        require(!utilizado,         "Um perfil ja esta guardado!");
        require(msg.value >= preco, "Precisa receber o valor correto!");

        envia_troco();
        envia_pagamento();

        perfil = _perfil;
        dono = _dono;
        utilizado = true;

        emit Guardado(perfil, dono);
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
}
