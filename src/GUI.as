/*
 * Based on GUI.as by RuteNL & GUI.as by Blackfeather
 * https://github.com/RuurdBijlsma/tm-split-speeds/blob/master/src/GUI.as
 * https://openplanet.dev/plugin/checkpointsplits
 */

namespace GUI
{
    /* Colors */
    vec4 sameTimeColour = vec4(0.780, 0.780, 0.780, .6);
    vec4 fasterColour = vec4(0.149, 0.149, 0.980, .6);
    vec4 slowerColour = vec4(0.980, 0.149, 0.149, .6);

    vec4 textColour = vec4(1, 1, 1, 1);

    float scale = 1;
    int fontSize = 31;

    /* Used in code */
    string DifferenceText;

    // 0 = same, -1 = faster, 1 = slower
    int DifferenceTextType = 0;

    wstring PreviousCheckpointDelta;

    uint64 TimeNow = 0;

    int font;

    void Initialize()
    {
	    font = nvg::LoadFont("assets/OswaldMono-Regular.ttf");
    }

    void CheckpointUpdate()
    {
        TimeNow = Time::Now;
        UpdatePreviousCheckpointDelta();
    }

    void Render()
    {
        bool IsGameUIVisible = UI::IsGameUIVisible();
        
        if(IsGameUIVisible && !ShowWithHudVisible) return;
        if(!IsGameUIVisible && !ShowWithHudHidden) return;
    
        if (AutoHide && TimeNow + 3000 <= Time::Now)
        {
            DifferenceText = "";
            return;
        }

        float h = float(Draw::GetHeight());
        float w = float(Draw::GetWidth());
        float scaleX, scaleY, offsetX = 0;
        if(w / h > 16. / 9) {
            double correctedW = (h / 9.) * 16;
            scaleX = correctedW / 2560;
            scaleY = h / 1440;
            offsetX = (w - correctedW) / 2;
        } else {
            scaleX = w / 2560;
            scaleY = h / 1440;
        }

        nvg::Save();
        nvg::Translate(offsetX, 0);
        nvg::Scale(scaleX, scaleY);
        RenderDefaultUI();
        nvg::Restore();
    }

    void RenderDefaultUI()
    {
        uint boxWidth = uint(scale * boxWidthfactor);
        uint boxHeight = uint(scale * 56);
        uint padding = 7;
        uint x = uint(anchorX * 2560 - boxWidth / 2);
        uint y = uint(anchorY * 1440 - boxHeight / 2);
        nvg::FontFace(font);

        nvg::FontSize(scale * fontSize);

        // Draw difference
        if(DifferenceText == "")
        {
            return;
        }

        // Draw box
        nvg::BeginPath();
        nvg::Rect(x, y, boxWidth, boxHeight);

        vec4 boxColour;
        if(DifferenceTextType == 1) boxColour = slowerColour;
        else if(DifferenceTextType == -1) boxColour = fasterColour;
        else boxColour = sameTimeColour;

        nvg::FillColor(boxColour);
        nvg::Fill();
        nvg::ClosePath();
        // Draw text
        nvg::TextAlign(nvg::Align::Right | nvg::Align::Middle);
        nvg::FillColor(textColour);
        nvg::FontSize(fontSize);
        nvg::TextBox(x + padding, y + boxHeight / 2, boxWidth - 2 * padding, DifferenceText);
    }

    void UpdatePreviousCheckpointDelta()
    {
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        NGameLoadProgress_SMgr@ loadMgr = app.LoadProgress; 
        CTrackManiaNetwork@ network = cast<CTrackManiaNetwork>(app.Network);

        if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.UILayers.Length > 0)
        {
            MwFastBuffer<CGameUILayer@> uilayers = network.ClientManiaAppPlayground.UILayers;

            for (uint i = 0; i < uilayers.Length; i++)
            {
                CGameUILayer@ curLayer = uilayers[i];
                int start = curLayer.ManialinkPageUtf8.IndexOf("<");
                int end = curLayer.ManialinkPageUtf8.IndexOf(">");

                if (start != -1 && end != -1)
                {
                    string manialinkname = curLayer.ManialinkPageUtf8.SubStr(start, end);
                    if (manialinkname.Contains("UIModule_Race_Checkpoint"))
                    {
                        CGameManialinkLabel@ MLDiffTimeLabel = cast<CGameManialinkLabel@>(curLayer.LocalPage.GetFirstChild("label-race-diff"));

                        dictionary RelativeDifference = RelativeDifference::getString(MLDiffTimeLabel.Value, PreviousCheckpointDelta);

                        
                        RelativeDifference.Get('DifferenceText', DifferenceText);
                        print(DifferenceText);
                        RelativeDifference.Get('DifferenceTextType', DifferenceTextType);
                        print(DifferenceTextType);

                        PreviousCheckpointDelta = MLDiffTimeLabel.Value;
                    }
                }
            }
        }
    }
}
