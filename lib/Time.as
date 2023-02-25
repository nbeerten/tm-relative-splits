namespace Time {
    string correctFormat(uint64 time, bool fractions = true, bool forceMinutes = true, bool forceHours = false, bool short = false) {
        string TimeFormat = Time::Format(time, fractions, forceMinutes, forceHours, short);
        if(Regex::IsMatch(TimeFormat, '([0-9]):.*', Regex::Flags::CaseInsensitive)) {
            TimeFormat = '0' + TimeFormat;
        } 

        return TimeFormat;
    }
}