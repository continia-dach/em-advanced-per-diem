pageextension 62082 "EMADV Per Diem Group Card Ext." extends "CEM Per Diem Group Card"
{
    layout
    {
        addafter(Default)
        {
            field("Calculation rule set"; Rec."Calculation rule set")
            {
                ApplicationArea = All;
            }
            field("Preferred rate"; Rec."Preferred rate")
            {
                ApplicationArea = All;
            }

            group(ATRulesetFields)
            {
                Visible = ShowAustrianRuleFields;
                Caption = 'Austrian rule setup';
                field("Min. foreign country duration"; Rec."Min. foreign country duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Minimum hours that needs to be tracked for a foreign country per diem trip';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShowAustrianRuleFields := (Rec."Calculation rule set" in [Rec."Calculation rule set"::Austria24h, Rec."Calculation rule set"::AustriaByDay]);
    end;

    var
        ShowAustrianRuleFields: Boolean;
}
