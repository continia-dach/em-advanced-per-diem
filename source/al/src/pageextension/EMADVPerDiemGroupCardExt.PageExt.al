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
            field("Minimum Stay (hours)"; Rec."Minimum Stay (hours)")
            {
                ApplicationArea = All;
            }
            // field("Auto-split AT per diem meal"; Rec."Auto-split AT per diem meal")
            // {
            //     ApplicationArea = All;
            // }
            field("Time-based meal deductions"; Rec."Time-based meal deductions")
            {
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Experimental';
                trigger OnValidate()
                begin
                    Error('In development!');
                end;

            }
        }

        addafter(PostingGroups)
        {
            group(ATRulesetFields)
            {
                Visible = ShowAustrianRuleFields;
                Caption = 'Austrian rule setup';
                field("Min. foreign country duration"; Rec."Min. Stay Foreign ctry. (h)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Minimum hours that needs to be tracked for a foreign country per diem trip';
                }
            }
            group(MealTimes)
            {
                Visible = (ShowAustrianRuleFields and Rec."Time-based meal deductions");
                Caption = 'Meal times';

                group(BreakfastTimes)
                {
                    ShowCaption = false;
                    field("Breakfast from-time"; Rec."Breakfast from-time")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Defines the from-time, where the system will deduct the breakfast amount';
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            CalculateMealToTimes();
                        end;
                    }
                    field("Breakfast to-time"; ToTimeBreakfast)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Defines the to-time, where the system will deduct the breakfast amount';
                    }
                }
                group(LunchTime)
                {
                    ShowCaption = false;
                    field("Lunch from-time"; Rec."Lunch from-time")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Defines the from-time, where the system will deduct the lunch amount';
                        ShowMandatory = true;
                        trigger OnValidate()
                        begin
                            CalculateMealToTimes();
                        end;
                    }
                    field("Lunch to-time"; ToTimeLunch)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Defines the to-time, where the system will deduct the lunch amount';
                    }
                }
                group(DinnerTime)
                {
                    ShowCaption = false;
                    field("Dinner from-time"; Rec."Dinner from-time")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Defines the from-time, where the system will deduct the dinner amount';
                        ShowMandatory = true;
                        trigger OnValidate()
                        begin
                            CalculateMealToTimes();
                        end;

                    }
                    field("Dinner to-time"; ToTimeDinner)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Defines the to-time, where the system will deduct the dinner amount';
                    }
                }
            }
        }
    }

    actions
    {
        addfirst(Navigation)
        {
            action(MealDeductions)
            {
                ApplicationArea = All;
                Caption = 'Group meal deductions';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = LineDiscount;

                RunObject = page "EMADV Meal Deduction List";
                RunPageLink = "Per Diem Group Code" = field(Code), "Destination Country/Region" = filter(''), "Accommodation Allowance Code" = filter(''), "Start Date" = filter(0D);
            }
            action(PerDiemRates)
            {
                ApplicationArea = All;
                Caption = 'Rates';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Travel;

                RunObject = page "EMADV Per Diem Rate List";
                RunPageLink = "Per Diem Group Code" = field(Code);
                RunPageMode = View;
            }
        }
    }

    local procedure CalculateMealToTimes()
    begin

        if Rec."Lunch from-time" <> 0T then
            ToTimeBreakfast := Rec."Lunch from-time" - 1
        else
            ToTimeBreakfast := 0T;

        if Rec."Dinner from-time" <> 0T then
            ToTimeLunch := rec."Dinner from-time" - 1
        else
            ToTimeLunch := 0T;

        if Rec."Breakfast from-time" <> 0T then
            ToTimeDinner := rec."Breakfast from-time" - 1
        else
            ToTimeDinner := 0T;
    end;

    trigger OnAfterGetRecord()
    begin
        ShowAustrianRuleFields := (Rec."Calculation rule set" in [Rec."Calculation rule set"::Austria24h, Rec."Calculation rule set"::AustriaByDay]);
        CalculateMealToTimes();
    end;

    var
        ShowAustrianRuleFields: Boolean;
        ToTimeBreakfast: Time;
        ToTimeLunch: Time;
        ToTimeDinner: Time;
}
