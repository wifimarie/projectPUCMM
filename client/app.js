/*
    Funciones ejecutadas al iniciar la pàgina web concernientes a la conexión de la blockchain y el contrato inteligente
*/
App = {
    // objeto en el que se guardará los contratos
    contracts: {},
    // init ejecuta las funciones automticamente al iniciar la pàgina
       init: async () => {
        await App.loadWeb3();
        await App.loadAccount();
        await App.loadContract();
        //await App.inicio_sesion();
        //await App.render();
        //await App.renderDevicesLogs();
        console.log('Loaded');
    },
    // funcion para validar que el navegador tiene corriendo el objeto ethereum
    loadWeb3: async () => {
        if (window.ethereum) {
            // proveedor
          App.web3Provider = window.ethereum;
          await window.ethereum.request({ method: "eth_requestAccounts" });
        } else if (window.web3) {
          web3 = new Web3(window.web3.currentProvider);
        } else {
          console.log(
            "No ethereum browser is installed. Try it installing MetaMask "
          );
        }
      },
      // Funcion para cargar cuenta 
      loadAccount: async () => {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        App.account = accounts[0]; // obtiene la primera cuenta que encuentre en la billetera
      },
      
      // Funcion para cargar una instancia del contrato inteligente de truffle
      loadContract: async () => {
        try {
        // llamo al objeto Contract.json
          const res = await fetch("Contract.json");
        // convierto la promesa a formato json para obtener el abi del contrato
          const ContractJSON = await res.json();
        // por medio de truffle, interactuamos con el contrato
        // guardamos en el objeto contracts de init el objeto Contract que es el contrato
          App.contracts.Contract = TruffleContract(ContractJSON);
        // asignamos el proveedor, en este caso, metamask
          App.contracts.Contract.setProvider(App.web3Provider);
        // instanciamos contrato para usar sus metodos y funciones
          App.contract = await App.contracts.Contract.deployed();
        } catch (error) {
          console.error(error);
        }
      }, inicio_sesion: async (matricula, pass) => {
        try {
          //const credenciales = await App.contract.inicio_sesion(matricula, pass, {from: App.account, });
          //console.log(credenciales.logs[0].args);
          // window.location.reload();
          console.log("Ha iniciado sesión: "+ matricula);
        } catch (error) {
          console.error(error);
        }
    },
      // fundion para mostrar dispositivos conectados
      render: async () => {
        const connectedDevices = await App.contract.numDevice();
        const counterNumDevices = connectedDevices.toNumber();
        console.log(counterNumDevices)
        document.getElementById("connected-devices").innerText = counterNumDevices;
      },
      renderDevicesLogs: async () => {
      const connectedDevices = await App.contract.numDevice();
      const counterNumDevices = connectedDevices.toNumber();
      let html = "";
      var table = document.getElementById('myTable')

    for (let i = 1; i <= counterNumDevices; i++) {
      const dispositivo = await App.contract.device(i);
      const idDispositivo = dispositivo[0].toNumber();
      const  estadoDispositivo = dispositivo[1];
      const  dispositivoAddedAt = dispositivo[2];
      const  nombreDispositivo = dispositivo[3];
      const  dataSensor = dispositivo[4];

      // imprimiendo a ver

      var row = `<tr>
      <th>${idDispositivo}</th>
      <td>${nombreDispositivo}</td>
      <td>${estadoDispositivo}</td>
      <td>${new Date(dispositivoAddedAt * 1000).toLocaleString()}</td>
					  </tr>`
			table.innerHTML += row

      console.log("id: " + idDispositivo);
      console.log("Nombre del device: "+nombreDispositivo);
      console.log("Estado del dispositivo: "+ estadoDispositivo);
      console.log("Fecha agregada: "+new Date(dispositivoAddedAt * 1000).toLocaleString());
      console.log("Temperatura obtenida: "+ dataSensor + " °C");

    }

    //document.querySelector("#logs").innerHTML = html;
  },
      // Funcion empleada para agregar el dispositivo al contrato
      agregarDispositivo: async (id, nombre) => {
        try {
          const result = await App.contract.agregarDispositivo(id, nombre, {from: App.account, });
          console.log(result.logs[0].args);
          window.location.reload();
        } catch (error) {
          console.error(error);
        }
      }
}

App.init()