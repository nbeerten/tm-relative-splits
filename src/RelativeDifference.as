namespace RelativeDifference {
    dictionary getString(const wstring &in a_CurCPDelta, const wstring &in a_PrevCPDelta) {
        string DifferenceText;
        int DifferenceTextType = 0;
        
        int CurCPType = a_CurCPDelta.StartsWith("-") ? -1 : 1;
        int ParsedCurCPDelta = Time::ParseRelativeTime(a_CurCPDelta);
        int CurCPDelta = CurCPType * ParsedCurCPDelta;

        int PrevCPType = a_PrevCPDelta.StartsWith("-") ? -1 : 1;
        int ParsedPrevCPDelta = Time::ParseRelativeTime(a_PrevCPDelta);
        int PrevCPDelta = PrevCPType * ParsedPrevCPDelta;

        
        int Difference = CurCPDelta - PrevCPDelta;
        int DifferenceType = (Difference < 0) ? -1 : 1;
        uint64 ParsedDifference = Math::Abs(Difference);
        string ParsedDifferenceText = Time::correctFormat(ParsedDifference, true, true, false, false);
        
        if(CurCPDelta == 0 && PrevCPDelta == 0 || CurCPDelta == PrevCPDelta) {
            DifferenceText = "";
            DifferenceTextType = 0;
        } else if(Regex::IsMatch(ParsedDifferenceText, "[0.:]*") && CP::curCP > 1) {
            DifferenceText = ParsedDifferenceText;
            DifferenceTextType = 0;
        } else if(CP::curCP > 1) {
            DifferenceText = (DifferenceType < 0 ? "-" : "+" ) + ParsedDifferenceText;
            DifferenceTextType = DifferenceType;
        } else {
            DifferenceText = "";
            DifferenceTextType = 0;
        }

        dictionary returnDict = {{'DifferenceText', DifferenceText}, {'DifferenceTextType', DifferenceTextType}};
        return returnDict;
    }
}