// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract RedeSocialNotarizada {
    string  public perfil;          // nome do perfil que estamos salvando
    address public dono;            // carteira do dono
    uint256 public preco;           // preco em wei para salvar nesse contrato
    address public criador;         // criador do contrato

    // Evento é emitido quando o perfil é guardado
    event Guardado(string _perfil, address _dono);

    /**
     * @dev Armazena o preco para usar o contrato
     */
    constructor(uint256 _preco) {
        preco = _preco;
        criador = msg.sender;
    }
    
    /**
     * @dev Permite salvar um nome de perfil associado a um endereco de carteira. Requer que seja enviado valor a partir do definido no construtor do contrato.
     * @param _perfil String representando o nome do perfil a ser salvo.
     * @param _dono Endereco da carteira do dono do perfil.
     */
    function guardar(string calldata _perfil, address _dono) public payable {
        require(dono == address(0), "Um perfil ja esta guardado!");
        require(msg.value >= preco, "Precisa receber o valor correto!");
        
        // verifica se é preciso enviar troco
        if (msg.value > preco){
            uint restante = msg.value - preco;
            payable(msg.sender).transfer(restante);
        }
        // envia o resto do saldo do contrato para o criador
        payable(criador).transfer(address(this).balance);

        // salva o perfil e o dono
        perfil = _perfil;
        dono = _dono;

        emit Guardado(perfil, dono);
    }
}
