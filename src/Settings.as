[Setting hidden category="General" name="Enabled"]
bool Enabled = true;

[Setting hidden category="General" name="Show"]
bool Show = true;

[Setting hidden category="General" name="AutoHide"]
bool AutoHide = true;

[Setting hidden category="General" name="ShowWithHudVisible"]
bool ShowWithHudVisible= true;

[Setting hidden category="General" name="ShowWithHudHidden"]
bool ShowWithHudHidden = false;

[Setting hidden name="X position" min=0 max=1 category="General"]
float anchorX = 0.497;

[Setting hidden name="Y position" min=0 max=1 category="General"]
float anchorY = .368;

[Setting hidden category="General" name="boxWidthfactor"]
float boxWidthfactor = 145;

[SettingsTab name="General" icon="Cog"]
void RenderSettingsGeneral()
{
    if(UI::Button('Reset to default')) {
        Enabled = true;
        Show = true;
        AutoHide = true;

        ShowWithHudVisible = true;
        ShowWithHudHidden = false;

        anchorX = 0.497;
        anchorY = 0.368;
        boxWidthfactor = 145;
    }
    UI::Separator();

    if(UI::BeginTable("checkboxes", 2, UI::TableFlags::NoBordersInBody|UI::TableFlags::NoPadOuterX|UI::TableFlags::NoPadInnerX|UI::TableFlags::SizingStretchSame)) {
        UI::TableNextColumn();
        Enabled = UI::Checkbox("Enabled", Enabled);
	    Show = UI::Checkbox("Show", Show);
	    AutoHide = UI::Checkbox("Automatically Hide", AutoHide);
        UI::TableNextColumn();
        ShowWithHudVisible = UI::Checkbox("Show when HUD is visible", ShowWithHudVisible);
        ShowWithHudHidden = UI::Checkbox("Show when HUD is hidden", ShowWithHudHidden);
    }
    UI::EndTable();

    UI::Separator();

    if(UI::BeginTable("anchor", 2, UI::TableFlags::NoBordersInBody|UI::TableFlags::NoPadOuterX|UI::TableFlags::NoPadInnerX|UI::TableFlags::SizingStretchSame)) {
        UI::TableNextColumn();
        UI::TextWrapped('Position');
        anchorX = UI::SliderFloat("X", anchorX, 0, 1);
        anchorY = UI::SliderFloat("Y", anchorY, 0, 1);
        UI::TableNextColumn();
        UI::TextWrapped('Size');
        boxWidthfactor = UI::InputFloat('Width', boxWidthfactor);
    }
    UI::EndTable();
}