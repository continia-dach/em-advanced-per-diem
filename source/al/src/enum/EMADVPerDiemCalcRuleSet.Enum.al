enum 62082 "EMADV Per Diem Calc. Rule Set" implements "EMADV IPerDiemRuleSetProvider"
{
    Extensible = true;
    UnknownValueImplementation = "EMADV IPerDiemRuleSetProvider" = "EMADV PD Rule Set Default";
    DefaultImplementation = "EMADV IPerDiemRuleSetProvider" = "EMADV PD Rule Set Default";

    value(0; "Default")
    {
        Caption = 'Default';
        Implementation = "EMADV IPerDiemRuleSetProvider" = "EMADV PD Rule Set Default";
    }
    value(10; Germany)
    {
        Caption = 'Germany';
        Implementation = "EMADV IPerDiemRuleSetProvider" = "EMADV PD Rule Set DE";
    }
    value(20; Austria24h)
    {
        Caption = 'Austria 24h';
        Implementation = "EMADV IPerDiemRuleSetProvider" = "EMADV PD Rule Set AT 24h";
    }
    value(24; AustriaByDay)
    {
        Caption = 'Austria per calendar day';
        Implementation = "EMADV IPerDiemRuleSetProvider" = "EMADV PD Rule Set AT CalDay";
    }
}
