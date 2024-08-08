// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract RedeSocialNotarizada {
    string  public perfil;      // nome do perfil que estamos salvando
    address public dono;        // carteira do dono
    uint256 public preco;       // preco em wei para salvar nesse contrato
    address public criador;     // criador do contrato
    bool public utilizado;      // contrato ja foi utilizado?

    // 14. Evento para ser emitido quando o perfil é guardado - https://docs.soliditylang.org/en/develop/abi-spec.html#events
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

        envia_troco(preco - msg.value);
        envia_pagamento();

        perfil = _perfil;
        dono = _dono;
        utilizado = true;

        emit Guardado(perfil, dono);        // 15. Emitir o evento
    }

    function envia_troco(uint _valor) private {
        if (_valor > 0){
            payable(msg.sender).transfer(_valor);
        }
    }

    function envia_pagamento() private {
        // envia o resto do saldo do contrato para o criador
        payable(criador).transfer(address(this).balance);
    }
}
