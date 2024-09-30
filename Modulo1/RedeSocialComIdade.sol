// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract RedeSocial {

    string perfil;
    address dono;

    function guardar(string calldata _perfil, address _dono) public {
        perfil = _perfil;
        dono = _dono;
    }

    function recuperar() public view returns (string memory _perfil, address _dono){
        return (perfil, dono);
    }
}

contract RedeSocialComIdade is RedeSocial {
    uint private idade;

    function guardarComIdade(string calldata _perfil, address _dono, uint _idade) public {
        guardar(_perfil, _dono);
        idade = _idade;
    }

    function recuperarIdade() public view returns (uint) {
        return idade;
    }
}