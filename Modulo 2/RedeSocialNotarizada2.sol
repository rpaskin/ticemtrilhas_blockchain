// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract RedeSocialNotarizada {
    string  public perfil;      // nome do perfil que estamos salvando
    address public dono;        // carteira do dono
    uint256 public preco;       // preco em wei para salvar nesse contrato
    address public criador;     // criador do contrato
    bool    public utilizado;   // contrato ja foi utilizado?

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
        // require(msg.value == preco, "Precisa receber o valor correto!");
        require(msg.value >= preco, "Precisa receber o valor correto!");        // 10. Tem que receber no mínimo o valor correto (TROCO)

        envia_troco();                      // 11. ABSTRACAO TROCO
        envia_pagamento();                  // 13. ABSTRACAO PAGAMENTO SERVICO NOTARIAL

        perfil = _perfil;
        dono = _dono;
        utilizado = true;
    }

    function envia_troco() private {     // 12. PRIVATE; fazer sem o private primeiro (HACKER imagina se pudesse enviar um valor a qualquer hora para o msg.sender)
        uint256 valor = msg.value - preco;
        if (valor > 0){
            payable(msg.sender).transfer(valor);
        }
    }

    function envia_pagamento() private {                        // 13. PRIVATE
        // envia o resto do saldo do contrato para o criador
        payable(criador).transfer(address(this).balance);       // 14. THIS - Contract related e address(this) e .balance Members of Address Types https://docs.soliditylang.org/en/develop/units-and-global-variables.html
    }
}
