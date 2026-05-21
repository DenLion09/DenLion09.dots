const Header = ({ sessionsArr }: { sessionsArr: Array[object] }) => {
  return (
    <header>
      <h1 className="nav-app-name">Wether App</h1>
      <nav>{sessionsArr.map(sessionsArr, () => console.log(1))}</nav>
    </header>
  );
};

export default Header;
