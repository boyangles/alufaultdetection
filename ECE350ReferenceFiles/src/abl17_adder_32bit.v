module abl17_adder_32bit(a, b, cin, sum);
	input [31:0] a;
	input [31:0] b;
	input cin;
	output [31:0] sum;
	
	wire [1:0] cin1;
	wire [1:0] gen1;
	wire [1:0] prop1;
	
	abl17_adder_16bit adder_16bit_1(.a(a[15:0]), .b(b[15:0]), .cin(cin), .gen(gen1[0]), .prop(prop1[0]), .sum(sum[15:0]));
	abl17_adder_16bit adder_16bit_2(.a(a[31:16]), .b(b[31:16]), .cin(cin1[0]), .gen(gen1[1]), .prop(prop1[1]), .sum(sum[31:16]));

	assign cin1[0] = gen1[0] | (prop1[0] & cin);
	assign cin1[1] = gen1[1] | (gen1[0] & prop1[1]) | (cin & prop1[0] & prop1[1]) ;
endmodule

////////////////////////////////////////////////////

module abl17_adder_32bit_fault(a, b, cin, ctrl_flip_16, ctrl_flip_4, sum);
	input [31:0] a;
	input [31:0] b;
	input cin;
	input ctrl_flip_16, ctrl_flip_4;
	output [31:0] sum;
	
	wire [1:0] cin1;
	wire [1:0] gen1;
	wire [1:0] prop1;
	
	abl17_adder_16bit_fault adder_16bit_1(.a(a[15:0]), .b(b[15:0]), .cin(cin), .ctrl_flip_16(ctrl_flip_16), .ctrl_flip_4(1'b0), .gen(gen1[0]), .prop(prop1[0]), .sum(sum[15:0]));
	abl17_adder_16bit_fault adder_16bit_2(.a(a[31:16]), .b(b[31:16]), .cin(cin1[0]), .ctrl_flip_16(1'b0), .ctrl_flip_4(ctrl_flilp_4), .gen(gen1[1]), .prop(prop1[1]), .sum(sum[31:16]));

	assign cin1[0] = gen1[0] | (prop1[0] & cin);
	assign cin1[1] = gen1[1] | (gen1[0] & prop1[1]) | (cin & prop1[0] & prop1[1]) ;
endmodule

////////////////////////////////////////////////////

module abl17_adder_16bit(a, b, cin, gen, prop, sum);
	input [15:0] a;
	input [15:0] b;
	input cin;
	output gen;
	output prop;
	output [15:0] sum;
	
	wire [3:0] cin1;
	wire [3:0] gen1;
	wire [3:0] prop1;
	
	abl17_adder_4bit adder_4bit_1(.a(a[3:0]), .b(b[3:0]), .cin(cin), .gen(gen1[0]), .prop(prop1[0]), .sum(sum[3:0]));
	abl17_adder_4bit adder_4bit_2(.a(a[7:4]), .b(b[7:4]), .cin(cin1[0]), .gen(gen1[1]), .prop(prop1[1]), .sum(sum[7:4]));
	abl17_adder_4bit adder_4bit_3(.a(a[11:8]), .b(b[11:8]), .cin(cin1[1]), .gen(gen1[2]), .prop(prop1[2]), .sum(sum[11:8]));
	abl17_adder_4bit adder_4bit_4(.a(a[15:12]), .b(b[15:12]), .cin(cin1[2]), .gen(gen1[3]), .prop(prop1[3]), .sum(sum[15:12]));

	assign cin1[0] = gen1[0] | (prop1[0] & cin);
	assign cin1[1] = gen1[1] | (gen1[0] & prop1[1]) | (cin & prop1[0] & prop1[1]) ;
	assign cin1[2] = gen1[2] | (gen1[1] & prop1[2]) | (gen1[0] & prop1[1] & prop1[2]) | (cin & prop1[0] & prop1[1] & prop1[2]);
	assign cin1[3] = gen1[3] | (gen1[2] & prop1[3]) | (gen1[1] & prop1[2] & prop1[3]) | (gen1[0] & prop1[1] & prop1[2] & prop1[3]) | (cin & prop1[0] & prop1[1] & prop1[2] & prop1[3]);
	
	assign gen = gen1[3] | (gen1[2] & prop1[3]) | (gen1[1] & prop1[3] & prop1[2]) | (gen1[0] & prop1[3] & prop1[2] & prop1[1]);
	assign prop = prop1[0] & prop1[1] & prop1[2] & prop1[3];
endmodule

////////////////////////////////////////////////////

module abl17_adder_16bit_fault(a, b, cin, ctrl_flip_16, ctrl_flip_4, gen, prop, sum);
	input [15:0] a;
	input [15:0] b;
	input cin;
	input ctrl_flip_16, ctrl_flip_4;
	output gen;
	output prop;
	output [15:0] sum;
	
	wire [3:0] cin1;
	wire temp_cin1bit2;
	wire [3:0] gen1;
	wire [3:0] prop1;
	
	abl17_adder_4bit_fault adder_4bit_1(.a(a[3:0]), .b(b[3:0]), .cin(cin), .ctrl_flip_4(1'b0), .gen(gen1[0]), .prop(prop1[0]), .sum(sum[3:0]));
	abl17_adder_4bit_fault adder_4bit_2(.a(a[7:4]), .b(b[7:4]), .cin(cin1[0]), .ctrl_flip_4(1'b0), .gen(gen1[1]), .prop(prop1[1]), .sum(sum[7:4]));
	abl17_adder_4bit_fault adder_4bit_3(.a(a[11:8]), .b(b[11:8]), .cin(cin1[1]), .ctrl_flip_4(ctrl_flip_4), .gen(gen1[2]), .prop(prop1[2]), .sum(sum[11:8]));
	abl17_adder_4bit_fault adder_4bit_4(.a(a[15:12]), .b(b[15:12]), .cin(cin1[2]), .ctrl_flip_4(1'b0), .gen(gen1[3]), .prop(prop1[3]), .sum(sum[15:12]));

	assign cin1[0] = gen1[0] | (prop1[0] & cin);
	assign cin1[1] = gen1[1] | (gen1[0] & prop1[1]) | (cin & prop1[0] & prop1[1]) ;
	assign temp_cin1bit2 = gen1[2] | (gen1[1] & prop1[2]) | (gen1[0] & prop1[1] & prop1[2]) | (cin & prop1[0] & prop1[1] & prop1[2]);
	assign cin1[3] = gen1[3] | (gen1[2] & prop1[3]) | (gen1[1] & prop1[2] & prop1[3]) | (gen1[0] & prop1[1] & prop1[2] & prop1[3]) | (cin & prop1[0] & prop1[1] & prop1[2] & prop1[3]);
	
	flip_bit fault3(.currVal(temp_cin1bit2), .ctrl(ctrl_flip_16), .outVal(cin1[2]));
	
	assign gen = gen1[3] | (gen1[2] & prop1[3]) | (gen1[1] & prop1[3] & prop1[2]) | (gen1[0] & prop1[3] & prop1[2] & prop1[1]);
	assign prop = prop1[0] & prop1[1] & prop1[2] & prop1[3];
endmodule

////////////////////////////////////////////////////

module abl17_adder_4bit(a, b, cin, gen, prop, sum);
	input [3:0] a;
	input [3:0] b;
	input cin;
	output gen;
	output prop;
	output [3:0] sum;
	
	wire [3:0] cin1, gen1, prop1;
	
	abl17_adder_1bit adder1(.a(a[0]), .b(b[0]), .cin(cin), .gen(gen1[0]), .prop(prop1[0]), .sum(sum[0]));
	abl17_adder_1bit adder2(.a(a[1]), .b(b[1]), .cin(cin1[0]), .gen(gen1[1]), .prop(prop1[1]), .sum(sum[1]));
	abl17_adder_1bit adder3(.a(a[2]), .b(b[2]), .cin(cin1[1]), .gen(gen1[2]), .prop(prop1[2]), .sum(sum[2]));
	abl17_adder_1bit adder4(.a(a[3]), .b(b[3]), .cin(cin1[2]), .gen(gen1[3]), .prop(prop1[3]), .sum(sum[3]));

	assign cin1[0] = gen1[0] | (prop1[0] & cin);
	assign cin1[1] = gen1[1] | (gen1[0] & prop1[1]) | (cin & prop1[0] & prop1[1]) ;
	assign cin1[2] = gen1[2] | (gen1[1] & prop1[2]) | (gen1[0] & prop1[1] & prop1[2]) | (cin & prop1[0] & prop1[1] & prop1[2]);
	assign cin1[3] = gen1[3] | (gen1[2] & prop1[3]) | (gen1[1] & prop1[2] & prop1[3]) | (gen1[0] & prop1[1] & prop1[2] & prop1[3]) | (cin & prop1[0] & prop1[1] & prop1[2] & prop1[3]);
		
	assign gen = gen1[3] | (gen1[2] & prop1[3]) | (gen1[1] & prop1[3] & prop1[2]) | (gen1[0] & prop1[3] & prop1[2] & prop1[1]);
	assign prop = prop1[0] & prop1[1] & prop1[2] & prop1[3];
	
endmodule

////////////////////////////////////////////////////

module abl17_adder_4bit_fault(a, b, cin, ctrl_flip_4, gen, prop, sum);
	input [3:0] a;
	input [3:0] b;
	input cin;
	input ctrl_flip_4;
	output gen;
	output prop;
	output [3:0] sum;
	
	wire [3:0] cin1, gen1, prop1;
	wire temp_cin1bit1;
	
	abl17_adder_1bit adder1(.a(a[0]), .b(b[0]), .cin(cin), .gen(gen1[0]), .prop(prop1[0]), .sum(sum[0]));
	abl17_adder_1bit adder2(.a(a[1]), .b(b[1]), .cin(cin1[0]), .gen(gen1[1]), .prop(prop1[1]), .sum(sum[1]));
	abl17_adder_1bit adder3(.a(a[2]), .b(b[2]), .cin(cin1[1]), .gen(gen1[2]), .prop(prop1[2]), .sum(sum[2]));
	abl17_adder_1bit adder4(.a(a[3]), .b(b[3]), .cin(cin1[2]), .gen(gen1[3]), .prop(prop1[3]), .sum(sum[3]));

	assign cin1[0] = gen1[0] | (prop1[0] & cin);
	assign temp_cin1bit1 = gen1[1] | (gen1[0] & prop1[1]) | (cin & prop1[0] & prop1[1]) ;
	assign cin1[2] = gen1[2] | (gen1[1] & prop1[2]) | (gen1[0] & prop1[1] & prop1[2]) | (cin & prop1[0] & prop1[1] & prop1[2]);
	assign cin1[3] = gen1[3] | (gen1[2] & prop1[3]) | (gen1[1] & prop1[2] & prop1[3]) | (gen1[0] & prop1[1] & prop1[2] & prop1[3]) | (cin & prop1[0] & prop1[1] & prop1[2] & prop1[3]);
	
	flip_bit fault4(.currVal(temp_cin1bit1), .ctrl(ctrl_flip_4), .outVal(cin1[1]));
	
	assign gen = gen1[3] | (gen1[2] & prop1[3]) | (gen1[1] & prop1[3] & prop1[2]) | (gen1[0] & prop1[3] & prop1[2] & prop1[1]);
	assign prop = prop1[0] & prop1[1] & prop1[2] & prop1[3];
	
endmodule

////////////////////////////////////////////////////

module abl17_adder_1bit(a, b, cin, gen, prop, sum);
	input a;
	input b;
	input cin;
	output gen;
	output prop;
	output sum;
	
	assign gen = a & b;
	assign prop = a | b;
	assign sum = (~a & ~b & cin) | (~a & b & ~cin) | (a & ~b & ~cin) | (a & b & cin);
endmodule

////////////////////////////////////////////////////
