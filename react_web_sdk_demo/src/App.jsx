import reactLogo from "./assets/react.svg";
import viteLogo from "/vite.svg";
import "./App.css";

function App() {
  const btnClick = () => {
    const url = "https://neodocs-test--sdk-react-web-ee217y6z.web.app";
    const sdk = window.open(url);

    window.addEventListener("message", function (e) {
      if (e.source === sdk) {
        e.preventDefault();
        const data = JSON.parse(e.data);
        if (!("message" in data)) {
          return console.log("Data from Flutter: ", data);
        }

        const msg = data["message"].toLowerCase();

        console.log("Message from Flutter: ", msg);

        if (msg == "userdata") {
          const obj = {
            userId: "userId",
            firstName: "firstName",
            lastName: "lastName",
            gender: "male",
            dateOfBirth: "1651047119",
            apiKey: "NCqeTHkBa2QTdwM3H2UXO4H9iQbb4N1eXNKbzVi0",
          };
          console.log("Sending data");
          sdk.postMessage(JSON.stringify(obj), '*');
        }
      } else {
        console.log(`Received message from ${e.origin}: ${e.data}`);
      }
    });
  };

  return (
    <>
      {/* <div>
        <a href="https://vitejs.dev" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div> */}
      <h1>React Integration App</h1>
      {/* <div className="card"> */}
        <button className="card" onClick={btnClick}>Scan Card</button>
        {/* <p>
          Edit <code>src/App.jsx</code> and save to test HMR
        </p> */}
      {/* </div> */}
      {/* <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p> */}
    </>
  );
}

export default App;
