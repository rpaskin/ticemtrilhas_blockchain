// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract RedeSocial {

    string  public  perfil;
    address private dono;

    function guardar(string calldata _perfil, address _dono) public {
        perfil = _perfil;
        guardar_dono(_dono);
    }

    function guardar_dono(address _dono) private {
        dono = _dono;
    }

    function verifica_dono(address _dono) public view returns (bool) {
        return (dono == _dono);
    }
}