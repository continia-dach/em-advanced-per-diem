page 62082 "EMADV AT Calc Helper"
{
    ApplicationArea = All;
    Caption = 'EMADV AT Calc Helper';
    PageType = Card;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(DepartureDT; DepartureDT)
                {
                    ApplicationArea = All;
                }

                field(ArrivalDT; ArrivalDT)
                {
                    ApplicationArea = All;
                }
                field(TripDuration; TripDuration)
                {
                    ApplicationArea = All;
                }

                field(Hours; Hours)
                {
                    ApplicationArea = All;
                }
                field(Days; Days)
                {
                    ApplicationArea = All;
                }

                field(HoursModRounded; HoursModRounded)
                {
                    ApplicationArea = All;
                }
                field(DaysRounded; DaysRounded)
                {
                    ApplicationArea = All;
                }


            }
            group(HourBasedRuleSet)
            {
                caption = '24Hour rule set';
                field(Rule24_12; Rule24_12)
                {
                    ApplicationArea = all;
                    Caption = 'Number of twelth to claim';
                }

            }
            group(DayBasedRuleSet)
            {
                caption = 'Day based rule set';
                group(FirstDay)
                {
                    Caption = 'First Day';
                    field(FirstDayEnd; FirstDayEnd)
                    {
                        ApplicationArea = all;
                    }
                    field(FirstDayDuration; FirstDayDuration)
                    {
                        ApplicationArea = all;
                    }
                    field(FirstDayTwelth; FirstDayTwelth)
                    {
                        ApplicationArea = All;
                    }
                }
                group(LastDay)
                {
                    Caption = 'Last Day';
                    field(LastDayBegin; LastDayBegin)
                    {
                        ApplicationArea = All;
                    }
                    field(LastDayDuration; LastDayDuration)
                    {
                        ApplicationArea = All;
                    }
                    field(LastDayTwelth; LastDayTwelth)
                    {
                        ApplicationArea = All;
                    }
                }
                group(Total)
                {
                    Caption = 'Trip Total';
                    field(InBetweenTwelth; InBetweenTwelth)
                    {
                        ApplicationArea = All;
                    }
                    field(RuleByDay_12; RuleByDay_12)
                    {
                        ApplicationArea = all;
                        Caption = 'Number of twelth to claim';
                    }
                }


            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Setup1DayMoreThan12)
            {
                trigger OnAction()
                begin
                    SetupTrip(20220904D, 083000T, 20220904D, 214500T);
                end;
            }

            action(Setup1DayLessThan12)
            {
                trigger OnAction()
                begin
                    SetupTrip(20220904D, 083000T, 20220904D, 140000T);
                end;
            }
            action(Setup2DayLessThan12)
            {
                trigger OnAction()
                begin
                    SetupTrip(20220904D, 200000T, 20220905D, 030000T);
                end;
            }
            action(Setup2DayTrip)
            {
                trigger OnAction()
                begin
                    SetupTrip(20220904D, 083000T, 20220906D, 170000T);
                end;
            }
            action(Calc)
            {
                ApplicationArea = All;
                Caption = 'Calc';
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Calc';

                trigger OnAction()
                var

                    TempHours: Decimal;
                    TempDays: Decimal;
                    TempDaysRounded: Decimal;
                    TempHoursModRounded: Decimal;
                begin
                    Clear(TripDuration);
                    Clear(Hours);
                    Clear(Days);
                    Clear(HoursModRounded);
                    Clear(DaysRounded);
                    Clear(Rule24_12);
                    Clear(FirstDayEnd);
                    Clear(FirstDayDuration);
                    Clear(FirstDayTwelth);
                    Clear(LastDayBegin);
                    Clear(LastDayDuration);
                    Clear(LastDayTwelth);
                    Clear(InBetweenDays);
                    Clear(InBetweenTwelth);
                    Clear(RuleByDay_12);

                    TripDuration := ArrivalDT - DepartureDT;
                    Hours := TripDuration / (1000 * 60 * 60); //1000ms * 60sec * 60min
                    Days := Hours / 24;
                    DaysRounded := Round(Days, 1, '<');
                    HoursModRounded := Round(Hours mod 24, 1, '>'); // Round up, as every started hour counts as 1

                    // Calc scheme for 24h per diem rule set
                    Rule24_12 := DaysRounded * 12;
                    if HoursModRounded > 12 then
                        Rule24_12 += 12
                    else
                        Rule24_12 += HoursModRounded;

                    // Calc scheme for "by day" based per diem rule set
                    if (DaysRounded = 0) and (DT2Date(DepartureDT) = DT2Date(ArrivalDT)) then begin
                        if (HoursModRounded > 0) then
                            if HoursModRounded > 12 then
                                RuleByDay_12 := 12
                            else
                                RuleByDay_12 := HoursModRounded;
                    end else begin
                        // Calc first date
                        FirstDayEnd := CreateDateTime(DT2Date(DepartureDT) + 1, 000000T);
                        FirstDayDuration := FirstDayEnd - DepartureDT;
                        newProcedure(TempHours, TempDays, TempDaysRounded, TempHoursModRounded);
                        If TempHoursModRounded > 12 then
                            FirstDayTwelth := 12
                        else
                            FirstDayTwelth := TempHoursModRounded;

                        // Calc last date
                        LastDayBegin := CreateDateTime(DT2Date(ArrivalDT), 000000T);
                        LastDayDuration := ArrivalDT - LastDayBegin;
                        TempHours := LastDayDuration / (1000 * 60 * 60); //1000ms * 60sec * 60min
                        TempDays := TempHours / 24;
                        TempDaysRounded := Round(TempDays, 1, '<');
                        TempHoursModRounded := Round(TempHours mod 24, 1, '>');  // Round up, as every started hour counts as 1
                        If TempHoursModRounded > 12 then
                            LastDayTwelth := 12
                        else
                            LastDayTwelth := TempHoursModRounded;

                        // Calc in-between dates
                        InBetweenDays := (DT2Date(ArrivalDT) - 1) - (DT2Date(DepartureDT));
                        InBetweenTwelth := InBetweenDays * 12;

                        RuleByDay_12 := FirstDayTwelth + InBetweenTwelth + LastDayTwelth;
                    end;
                end;
            }

        }
    }
    var
        DepartureDT: DateTime;
        ArrivalDT: DateTime;
        TripDuration: Duration;
        Days: Decimal;
        DaysRounded: Decimal;
        HoursModRounded: Decimal;
        Hours: Decimal;
        Rule24_12: Decimal;
        RuleByDay_12: Decimal;
        FirstDayEnd: DateTime;
        FirstDayDuration: Duration;
        FirstDayTwelth: Decimal;
        LastDayTwelth: Decimal;
        InBetweenTwelth: Decimal;
        LastDayBegin: DateTime;
        LastDayDuration: Duration;
        InBetweenDays: Integer;

    local procedure newProcedure(var TempHours: Decimal; var TempDays: Decimal; var TempDaysRounded: Decimal; var TempHoursModRounded: Decimal)
    begin
        TempHours := FirstDayDuration / (1000 * 60 * 60); //1000ms * 60sec * 60min
        TempDays := TempHours / 24;
        TempDaysRounded := Round(TempDays, 1, '<');
        TempHoursModRounded := Round(TempHours mod 24, 1, '>');  // Round up, as every started hour counts as 1;
    end;


    trigger OnOpenPage()
    begin
        SetupTrip(20220904D, 083000T, 20220906D, 170000T);
    end;

    procedure SetupTrip(DepartueDate: Date; DepartureTime: Time; ArrivalDate: Date; ArrivalTime: Time)
    begin
        DepartureDT := CreateDateTime(DepartueDate, DepartureTime);
        ArrivalDT := CreateDateTime(ArrivalDate, ArrivalTime);
    end;
}
