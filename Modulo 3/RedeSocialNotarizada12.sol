// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract RedeSocialNotarizada is ERC20, Ownable, ERC20Permit {

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
    constructor(address initialOwner, uint256 _preco)
        ERC20("Rede Social Notarizada Token", "RSNT")
        Ownable(initialOwner)
        ERC20Permit("Rede Social Notarizada Token")
    {
        preco = _preco;
        criador = msg.sender;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Permite salvar um nome de perfil associado a um endereco de carteira. Requer que seja enviado o valor definido no construtor do contrato.
     * @param _perfil String representando o nome do perfil a ser salvo.
     * @param _dono Endereco da carteira do dono do perfil.
     */
    function guardar(string calldata _perfil, address _dono) public payable {
        require(registros[_dono].quando_criado == 0, "Um perfil ja esta guardado para este dono!");

        envia_pagamento();

        registros[_dono].perfil = _perfil;
        registros[_dono].quando_criado = block.timestamp;

        count++;

        emit Guardado(_perfil, _dono);
    }

    /**
    * @dev Envia o saldo restante do contrato para o criador
    */
    function envia_pagamento() private {
        transfer(owner(), preco);
    }
}

