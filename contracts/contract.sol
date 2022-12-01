// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Contract {
    address private _owner;
    uint256 public numDevice; // contador de dispositivos en la red
    uint256 bus; // sirve para tener el "id" del device buscado
    uint256 deviceID; // sirve para guardar momentaneamente el indice del device

    uint256 ingreso; // sera igual a la matricula usada durante la sesion
    string contras;
    bytes32 SID; // sesion id

    // estructuras
    struct Devices {
        uint256 uid; // id identificativo del dispositivo iot este valor es irremplazable
        bool estado; // estado del dispositivo: activo o inactivo
        uint256 addedAt; // tiempo añadido el bloque
        string nombre; // nombre del device
        uint256 TH; // dato a almacenar de sensor
    }

    // Estructura del funcionario que va a iniciar sesion. olo los usuarios que estén registrados podran hacer cambio a
    // los valores del dato del sensor o añadir nuevos dispositivos al contrato.
    struct AdminIoT {
        uint256 matricula;
        string nombre;
        bytes32 contrasena;
        bytes32 sesion; // hash del sesionID aleatorio que identific cada sesion
        bytes32 sesionIDTemporal; // almacenamiento temporal del sesionID en texto plano
        bool sesionActiva; // true: sesion activa o false: inactiva
        uint256 tiempoInicial;
    }

    /**
     * Set contract deployer as _owner
     */
    /*constructor() {
        _owner = payable(msg.sender); // 'msg.sender' is sender of current call, contract deployer for a constructor
        // emit _ownerSet(address(0), _owner);
    }*/

    constructor(uint256 matricula, string memory contrasena) {
        _owner = payable(msg.sender);
        adminsiot[matricula].matricula = matricula;
        adminsiot[matricula].nombre = "User"; // fixed Usuer
        adminsiot[matricula].contrasena = keccak256(
            abi.encodePacked(contrasena, adminsiot[matricula].sesion = "0")
        ); // toma los datos de los campos y los encripta generando el token o id de sesion
        adminsiot[matricula].sesionActiva = false;
        matriculas.push(matricula);
    }


    uint256[] matriculas; // numero de identificador de usuarios

    function kill() public onlyOwner {
        selfdestruct(payable(_owner));
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    // La función onlyOwner, se especifica para procesos en el contrato que solo la
    //cuenta que realizo el despliegue pueda modificar o consultar.

    modifier onlyOwner() {
        require(
            owner() == msg.sender,
            "Esta funcion solo puede ser llamada por el _owner"
        );
        _;
    }

    /* Función para cambiar de ownery solo puede ser aaccedida por el owner */
      function transferir_owner(address nuevo_owner) public virtual onlyOwner {
        _owner = payable(nuevo_owner);
    }

    mapping(uint256 => AdminIoT) adminsiot;
    mapping(uint256 => Devices) public device;

    // Eventos
    event DeviceToggledStatus(uint256 id, bool estado);

    event DeviceAdded(
        uint256 uid,
        bool estado,
        uint256 addedAt,
        string nombre,
        uint256 TH
    );

    
    function ingresar(uint256 matricula, string memory contrasena) public {
        require(_owner == msg.sender, "Alto ahi viejo");
        if (
            adminsiot[matricula].contrasena ==
            keccak256(abi.encodePacked(contrasena, adminsiot[matricula].nombre))
        ) {
            // Keccak256, a cryptographic function, is part of Solidity (SHA-3 Family). 2. The SHA-256 is weaker than Keccak-256
            adminsiot[matricula].sesionIDTemporal = keccak256(
                abi.encodePacked(block.timestamp, contrasena)
            );

            bytes32 sesionID = adminsiot[matricula].sesionIDTemporal;
            adminsiot[matricula].sesion = keccak256(abi.encodePacked(sesionID)); //
            adminsiot[matricula].tiempoInicial = block.timestamp;
            adminsiot[matricula].sesionActiva = true;
            ingreso = matricula;
            contras = contrasena;
            SID = adminsiot[matricula].sesionIDTemporal;
        }
    }

    function cerrarSesion() public {
        require(_owner == msg.sender, "Alto ahi viejo");
        adminsiot[ingreso].sesionActiva = false;
        adminsiot[ingreso].sesion = "0";
        adminsiot[ingreso].sesionIDTemporal = "0";
        ingreso = 0;
        contras = "0";
        SID = "0";
    }

    function verEstadoSesion(uint256 matricula) public view returns (bool) {
        if (adminsiot[matricula].sesionActiva) {
            return (true);
        } else {
            return (false);
        }
    }

    function enviarSesionID(uint256 matricula, string memory contrasena)
        public
        view
        returns (bytes32 sesionID)
    {
        if (
            adminsiot[matricula].sesionActiva &&
            adminsiot[matricula].contrasena ==
            keccak256(abi.encodePacked(contrasena, adminsiot[matricula].nombre))
        ) {
            sesionID = adminsiot[matricula].sesionIDTemporal;
            return sesionID;
        } else {
            return sesionID;
        }
    }

    /*
Función empleada por los devices para enviar la data al contrato por medio de su UID y solo será aceptada si dicho UID fue registrado por el Admin y la sesion de este esté activa.
*/
    function capturarData(uint256 id, uint64 _data) public returns (bool) {
        //validamos que el dispositivo que envia la data este registrado en el contrato
        if (buscarDispositivo(id) == true) {
            device[bus].TH = _data;
            return true;
        } else {
            return false;
        }
    }

    /*
Función empleada por añadir dispositivos por el admin desde la plataforma web
*/
    function agregarDispositivo(uint256 id, string memory _nombre)  public {
        require(_owner == msg.sender, "Alto ahi viejo");
               if (!buscarDispositivo(id)) {
            addDevice(id, _nombre);
        }
    }

    function addDevice(uint256 id, string memory _nombre) private {
        device[numDevice] = Devices(id, true, block.timestamp, _nombre, 0);
        numDevice++;
        emit DeviceAdded(id, true, block.timestamp, _nombre, 0);
    }

    /*
Función encargada de buscar el dispositivo y validad que esté registrado
*/
    function buscarDispositivo(uint256 id) private returns (bool) {
        for (uint256 i = 1; 1 <= deviceID; i++) {
            if (id == device[i].uid) {
                bus = i;
                return true;
            }
        }
        return false;
    }

    function toggleDeviceStatus(uint256 _id) public {
        Devices memory _device = device[_id];
        _device.estado = !_device.estado;
        device[_id] = _device;
        emit DeviceToggledStatus(_id, _device.estado);
    }
} // fin contrato