void Main() {
    GUI::Initialize();
}

void Update(float dt) {
    CP::Update();
}

void Render()
{
    CSmPlayer@ Player = GetPlayer();
    if (Player is null) return;
    
    CSmScriptPlayer@ ScriptPlayer = cast<CSmScriptPlayer@>(Player.ScriptAPI);
    if (ScriptPlayer is null && ScriptPlayer.Post != CSmScriptPlayer::EPost::CarDriver) return;
    if (!Enabled || !Show) return;
    
    GUI::Render();
}

void RenderMenu() {
	if (UI::MenuItem("\\$09f" + Icons::Flag + "\\$z Relative Splits", "", Show)) 
		Show = !Show;
}

CSmPlayer@ GetPlayer()
{
    CTrackMania@ app = cast<CTrackMania@>(GetApp());
    if(app is null) return null;

    CSmArenaClient@ playground = cast<CSmArenaClient@>(app.CurrentPlayground);
    if (playground is null) return null;

    if (playground.GameTerminals.Length < 1) return null;

    CGameTerminal@ terminal = playground.GameTerminals[0];
    if (terminal is null) return null;

    return cast<CSmPlayer@>(terminal.ControlledPlayer);
}