//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Panini {

    uint cantFiguritas = 300;
    uint figuritasPorPaquete = 5;

    mapping(address => uint) paquetes; 
    mapping(address => uint[]) public figuritas; 

    function obtenerPaquete() public {
        paquetes[msg.sender]++;
    }

    function cantidadPaquetes()  public view returns (uint cantPaquetes)  {
        return paquetes[msg.sender];
    }

    function agregarNFiguritas(uint cantidad) private {
        for (uint i; i < cantidad; i++) {
            figuritas[msg.sender].push(figuritaRandom(i));
        }
    }

    function figuritaRandom(uint i) private view returns (uint figurita) {
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp + i)));
        return rand % cantFiguritas;        
        
    }

    function obtenerFiguritas() public view returns (uint[] memory lista){
        return figuritas[msg.sender];
    }
    
    function abrirPaquete() public {
        require(paquetes[msg.sender] > 0, "No tenes paquetes para abrir");
        paquetes[msg.sender]--;
        agregarNFiguritas(figuritasPorPaquete);
    }

}




