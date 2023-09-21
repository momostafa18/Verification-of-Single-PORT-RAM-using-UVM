

module reg_file #(
    parameter DATA_WIDTH=32,
    REG_NO=16 , CLK_PRD = 5
) (
    input RdEN,WrEN,
    input [DATA_WIDTH-1:0] WrData,
    input [3:0] address,
    
    input clk,
    input reset,
    
    output reg RdData_Valid,
    output reg [DATA_WIDTH-1:0] RdData
);

reg [DATA_WIDTH-1:0] reg_bank [REG_NO-1:0];


integer i;



always @(posedge clk or negedge reset) 
begin
    if(!reset)
    begin
        RdData<=0;
        RdData_Valid<=0;

        reg_bank[2] <='b0_01000_0_1; //even_parity is the default  
        reg_bank[3] <='b0000_1000;
         
        for (i = 0; i <= REG_NO-1; i = i + 1) 
         begin     
            if(i != 2 && i != 3)
            begin
                reg_bank[i] <= 0;
            end
         end
    end

    else
    begin

        if(WrEN==1 && RdEN!=1)
          reg_bank[address]<=WrData;

        else if(RdEN==1 && WrEN!=1)
        begin
            RdData<=reg_bank[address];
            RdData_Valid <= 1;
        end

        else
        begin
            RdData_Valid <= 0;
        end
        
    end

end
endmodule