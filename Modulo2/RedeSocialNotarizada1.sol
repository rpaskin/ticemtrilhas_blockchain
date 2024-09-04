// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract RedeSocialNotarizada {
    string  public perfil;      // nome do perfil que estamos salvando
    address public dono;        // carteira do dono
    uint256 public preco;       // preco em wei para salvar nesse contrato

    // guarda quem criou o contrato
    address public criador;     // 4. criador do contrato (ADDRESS PESSOA/CONTRATO)

    // guarda se ja esta utilizado
    bool public utilizado;      // 5. o perfil ja foi guardado? sim/ não (BOOL)

    /**
     * @dev Armazena o preco e criador para usar o contrato
     */
    constructor(uint256 _preco) {
        preco = _preco;
        criador = msg.sender;   // 6. msg.sender (VARS ESPECIAIS)
        // utilizado = false;   // 7. Não é necessário (custo de GAS)
    }
    
    /**
     * @dev Permite salvar um nome de perfil associado a um endereco de carteira. Requer que seja enviado o valor correto definido no construtor do contrato.
     * @param _perfil String representando o nome do perfil a ser salvo.
     * @param _dono Endereco da carteira do dono do perfil.
     */
    function guardar(string calldata _perfil, address _dono) public payable {
        require(!utilizado,         "Um perfil ja esta guardado!");      // 8. Guarda um perfil por contrato, uma vez
        require(msg.value == preco, "Precisa receber o valor correto!");

        perfil = _perfil;
        dono = _dono;
        utilizado = true;   // 9. uma vez feito isso aqui, nunca mais o guardar irá funcionar (ver linha 31)
    }
}
