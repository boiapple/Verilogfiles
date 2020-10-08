module SPPA(input clk, input reset, input [31:0]A, input [31:0]B, output [31:0]Result);
    
    reg    [31:0] Num_shift; 
    reg    [7:0]  Larger_exp,Final_expo;
    reg    [22:0] Small_exp_ma,S_mantissa,L_mantissa,Large_ma,Final_mant;
    reg    [23:0] Add_mant,Add1_mant;
    reg    [7:0]  e1,e2;
    reg    [22:0] m1,m2;
    reg           s1,s2,Final_sign;
    reg    [3:0]  renorm_shift;
    integer signed   renorm_exp;
    reg    [31:0] Result1;

    assign Result = Result1;


    always @(*) begin

	e1 = A[30:23];
	e2 = B[30:23];
        m1 = A[22:0];
	m2 = B[22:0];
	s1 = A[31];
	s2 = B[31];
        
        if (e1  > e2) begin
            Num_shift           = e1 - e2;         
            Larger_exp           = e1;               
            Small_exp_ma  = m2;
            Large_ma      = m1;
        end
        
        else begin
            Num_shift           = e2 - e1;
            Larger_exp           = e2;
            Small_exp_ma  = m1;
            Large_ma      = m2;
        end

	if (e1 == 0 | e2 ==0) begin
	    Num_shift = 0;
	end
	else begin
	    Num_shift = Num_shift;
	end
	
	if (e1 != 0) begin
            Small_exp_ma  = {1'b1,Small_exp_ma[22:1]};
	    Small_exp_ma  = (Small_exp_ma >> Num_shift);
        end
	else begin
	    Small_exp_ma = Small_exp_ma;
	end

	if (e2!= 0) begin
            Large_ma      = {1'b1,Large_ma[22:1]};
	end
	else begin
	    Large_ma = Large_ma;
	end


            if (Small_exp_ma < Large_ma) begin

		S_mantissa = Small_exp_ma;
		L_mantissa = Large_ma;
            end
            else begin
			
		S_mantissa = Large_ma;
		L_mantissa = Small_exp_ma;
             end       

	
	if (e1!=0 & e2!=0) begin
		if (s1 == s2) begin
        		Add_mant = S_mantissa + L_mantissa;
		end else begin
			Add_mant = L_mantissa - S_mantissa;
		end
	end	
	else begin
		Add_mant = L_mantissa;
	end

	if (Add_mant[23]) begin
		renorm_shift = 4'd1;
		renorm_exp = 4'd1;
	end
	else if (Add_mant[22])begin
		renorm_shift = 4'd2;
		renorm_exp = 0;		
	end
	else if (Add_mant[21])begin
		renorm_shift = 4'd3; 
		renorm_exp = -1;
	end 
	else if (Add_mant[20])begin
		renorm_shift = 4'd4; 
		renorm_exp = -2;		
	end  
	else if (Add_mant[19])begin
		renorm_shift = 4'd5; 
		renorm_exp = -3;		
	end      

        Final_expo =  Larger_exp + renorm_exp;
	
	Add1_mant = Add_mant << renorm_shift;

	Final_mant = Add1_mant[23:1];  	

        
	if (s1 == s2) begin
		Final_sign = s1;
	end 

	if (e1 > e2) begin
		Final_sign = s1;	
	end else if (e2 > e1) begin
		Final_sign = s2;
	end
	else begin

		if (m1 > m2) begin
			Final_sign = s1;		
		end else begin
			Final_sign = s2;
		end
	end	
	
	Result1 = {Final_sign,Final_expo,Final_mant}; 

    end
    
    always @(posedge clk) begin
            if(reset) begin
                Num_shift <= #1 0;
            end
    end
    
endmodule