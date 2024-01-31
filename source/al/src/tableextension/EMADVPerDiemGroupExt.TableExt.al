tableextension 62081 "EMADV Per Diem Group Ext." extends "CEM Per Diem Group"
{
    fields
    {
        field(62080; "Calculation rule set"; Enum "EMADV Per Diem calc. rule set")
        {
            Caption = 'Calculation rule set';
            DataClassification = CustomerContent;
        }
        field(62085; "Preferred rate"; Enum "EMADV Per Diem Preferred Rates")
        {
            Caption = 'Preferred per diem rate';
            DataClassification = CustomerContent;
        }
        field(62086; "Min. foreign country duration"; Decimal)
        {
            Caption = 'Min. foreign country duration';
            DataClassification = CustomerContent;
        }
        field(62089; "Time-based meal deductions"; Boolean)
        {
            Caption = 'Time-based meal deductions';
            DataClassification = CustomerContent;
        }

        field(62090; "Breakfast from-time"; Time)
        {
            Caption = 'Breakfast from-time';
            DataClassification = CustomerContent;
        }
        field(62091; "Lunch from-time"; Time)
        {
            Caption = 'Lunch from-time';
            DataClassification = CustomerContent;
        }
        field(62092; "Dinner from-time"; Time)
        {
            Caption = 'Dinner from-time';
            DataClassification = CustomerContent;
        }
    }
}
