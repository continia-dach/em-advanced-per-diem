tableextension 62081 "EMADV Per Diem Group Ext." extends "CEM Per Diem Group"
{
    fields
    {
        field(62080; "Calculation rule set"; Enum "EMADV Per Diem calc. rule set")
        {
            Caption = 'Calculation rule set';
            DataClassification = CustomerContent;
        }
        // field(62081; "Auto-split AT per diem meal"; Boolean)
        // {
        //     Caption = 'Auto-split AT per diem meal';
        //     DataClassification = CustomerContent;
        // }
        field(62083; "Preferred rate"; Enum "EMADV Per Diem Preferred Rates")
        {
            Caption = 'Preferred per diem rate';
            DataClassification = CustomerContent;
        }
        field(62085; "Minimum Stay (hours)"; Integer)
        {
            Caption = 'Minimum Stay (hours)';
            DataClassification = CustomerContent;
        }

        field(62086; "Min. Stay Foreign ctry. (h)"; Decimal)
        {
            Caption = 'Min. stay hours in foreign countries';
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
