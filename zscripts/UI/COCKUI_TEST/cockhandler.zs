class CockHandler : StaticEventHandler {
    override void InterfaceProcess(ConsoleEvent e) {
        UIMenu men = UIMenu(Menu.GetCurrentMenu());
        if(men) {
            men.handleInterfaceEvent(e);
        }
    }
}