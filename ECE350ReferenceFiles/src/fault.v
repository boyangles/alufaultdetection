module fault(currVal, stuckAtVal, ctrl, outVal);
	input currVal, stuckAtVal, ctrl;
	output outVal;
	
	assign outVal = ctrl ? stuckAtVal : currVal;
endmodule

module flip_bit(currVal, ctrl, outVal);
	input currVal, ctrl;
	output outVal;
	
	assign outVal = ctrl ? ~currVal : currVal;
endmodule