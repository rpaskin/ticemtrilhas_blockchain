// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract RedeSocialNotarizada {
    string  public perfil;      // nome do perfil que estamos salvando
    address public dono;        // carteira do dono
    uint256 public preco;       // preco em wei para salvar nesse contrato

    /**
     * @dev Armazena o preco para usar o contrato
     */
    constructor(uint256 _preco) {
        preco = _preco;
    }
    
    /**
     * @dev Permite salvar um nome de perfil associado a um endereco de carteira. Requer que seja enviado o valor correto definido no construtor do contrato.
     * @param _perfil String representando o nome do perfil a ser salvo.
     * @param _dono Endereco da carteira do dono do perfil.
     */
    function guardar(string calldata _perfil, address _dono) public payable {
        require(msg.value == preco, "Precisa receber o valor correto!");

        perfil = _perfil;
        dono = _dono;
    }
}
