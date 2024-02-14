page 62086 "EMADV Calculation Detail FB"
{
    ApplicationArea = All;
    Caption = 'Day Details';
    PageType = CardPart;
    SourceTable = "CEM Per Diem Detail";

    layout
    {
        area(content)
        {
            group(PerDiemDate)
            {

                ShowCaption = false;
                field(Date; Rec.Date)
                {
                }
            }
            group(Meal)
            {
                Caption = 'Meal';

                field(Breakfast; Rec.Breakfast)
                {
                    DrillDown = true;
                    trigger OnDrillDown()
                    begin
                        Rec.Breakfast := not Rec.Breakfast;
                        Rec.Modify();
                        CurrPage.Update();
                    end;
                }
                field(Lunch; Rec.Lunch)
                {
                    DrillDown = true;
                    trigger OnDrillDown()
                    begin
                        Rec.Lunch := not Rec.Lunch;
                        Rec.Modify();
                        CurrPage.Update();
                    end;
                }
                field(Dinner; Rec.Dinner)
                {
                    DrillDown = true;
                    trigger OnDrillDown()
                    begin
                        Rec.Dinner := not Rec.Dinner;
                        Rec.Modify();
                        CurrPage.Update();
                    end;
                }
                field("Meal Allowance Amount"; Rec."Meal Allowance Amount")
                {
                }
                field("No. of Destinations"; Rec."No. of Destinations")
                {
                    Visible = false;
                }


            }
            group(Accommodation)
            {
                Caption = 'Accommodation';

                field("Accommodation Allowance"; Rec."Accommodation Allowance")
                {
                    DrillDown = true;
                    trigger OnDrillDown()
                    begin
                        Rec."Accommodation Allowance" := not Rec."Accommodation Allowance";
                        Rec.Modify();
                        CurrPage.Update();
                    end;
                }
                field("Accommodation Allowance Amount"; Rec."Accommodation Allowance Amount")
                {
                }
            }
        }
    }
}
