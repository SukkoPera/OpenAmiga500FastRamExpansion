/*
GottaGoFast FW for SukkoPera's OpenAmiga500FastRamExpansion
Copyright 2021 Matthew Harlum

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

// Config defines
`define autoconfig     // If disabled RAM is always mapped to $200000-9FFFFF
//`define cdtv         // Uncomment to build CDTV compatible version
//`define Offer_6M     // Offer 2MB+4MB block (useful for A2091/A590)
//`define Size_4MB     // 4MB Maximum, Only uses memory chips U7 & U8
`define snoopy         // Wireless Autoconfig, configures board last (requires KS 2 or higher!)

module SukkoGottaGoFast(
    input CLK,
    input RESETn,
    input UDSn,
    input LDSn,
    input ASn,
    inout [15:12] DBUS,
    input [23:16] ADDR_HI,
    input [6:1]   ADDR_LO,
    output reg mux_switch,
    output RAS0n,
    output RAS1n,
    output RAS2n,
    output RAS3n,
    output UCASn,
    output LCASn,
    output reg MA0,
    output reg MA1
    );

// Memory controller

reg ram_cycle;
reg access_ras;
reg access_ucas;
reg access_lcas;
reg refresh_ras;
reg refresh_cas;
reg [7:0] addr_match;
reg AS_last;
reg RWn;
`ifdef autoconfig
// Autoconfig
localparam [15:0] mfg_id  = 16'h07DB;
localparam [7:0]  prod_id = 8'd03;
localparam [15:0] serial  = 16'd420;

wire autoconfig_cycle;
reg shutup = 0;
reg CFGOUTn = 1;
reg configured;
reg [3:0] data_out;


`ifdef snoopy
// Autoconfig bus snooping
//
// For some reason Kickstart 2 and up scan the chain multiple times
// Thanks to this we can snoop on autoconfig cycles and then speak up once
// every other board is done being configured.
// No CFGIN connection needed!
reg [3:0] mfg_bad;
reg snoop_cfg;
reg snoop_cfg_next;
reg [3:0] snooped_autoconfig_state;
reg [3:0] dbus_latched;

always @(posedge CLK)
begin
  dbus_latched <= DBUS[15:12];
end

always @(posedge UDSn or negedge RESETn)
begin
  if (!RESETn) begin
    snoop_cfg_next <= 1'b0;
    snoop_cfg <= 1'b0;
    mfg_bad <= 'b0;
  end else if (ADDR_HI[23:16] == 8'hE8 & RWn) begin
    case (ADDR_LO[6:1])
    // Chain snooping
    //
    // If Reserved byte is not $F or manufacturer id is $FFFF then no board is answering
    // Once this happens we can set ourselves up to talk to the next autoconfig query
    'h0C>>1:
      if (!(dbus_latched == 4'hF)) begin // Reserved byte - Should be $FF
        snoop_cfg_next <= 1;
      end
    'h10>>1:
      if (dbus_latched == 4'hF) begin // Manufacturer ID - Should not be $FFFF
        mfg_bad[3] <= 1;
      end
    'h12>>1:
      if (dbus_latched == 4'hF) begin // Manufacturer ID - Should not be $FFFF
        mfg_bad[2] <= 1;
      end
    'h14>>1:
      if (dbus_latched == 4'hF) begin // Manufacturer ID - Should not be $FFFF
        mfg_bad[1] <= 1;
      end
    'h16>>1:
      if (dbus_latched == 4'hF) begin // Manufacturer ID - Should not be $FFFF
        mfg_bad[0] <= 1;
      end
    'h42>>1, 'h40>>1:
      if (snoop_cfg_next == 1) begin
       snoop_cfg <= 1;
      end else if (mfg_bad[3:0] == 4'b1111) begin
       snoop_cfg <= 1;
      end
    endcase
  end
end
`endif


reg [2:0] autoconfig_state;
localparam   Offer_8M = 3'b000,
// If offering 2MB + 4MB blocks you need to offer the 2MB block first
// This is because of a kickstart bug where the memory config overflows if there is already 2MB configured before another 4MB then 2MB is configured...
`ifdef Offer_6M
        Offer_2M = 3'b001,
        Offer_4M = 3'b010,
`else
        Offer_4M = 3'b001,
        Offer_2M = 3'b010,
`endif
        Offer_1M = 3'b011,
        SHUTUP   = 3'b100;

assign DBUS[15:12] = (autoconfig_cycle & RWn & !ASn & !UDSn) ? data_out[3:0] : 4'bZ;

assign autoconfig_cycle = (ADDR_HI[23:16] == 8'hE8) & snoop_cfg & CFGOUTn;

// Assert Config out at end of bus cycle
always @(posedge ASn or negedge RESETn)
begin
  if (!RESETn) begin
    CFGOUTn = 1'b1;
  end else begin
    CFGOUTn = !shutup;
  end
end

// Offers an 8MB block first, if there's no space offer 4MB, 2MB then 1MB before giving up
always @(posedge CLK or negedge RESETn)
begin
  if (!RESETn) begin
    data_out <= 4'bZ;
  end else if (autoconfig_cycle & RWn) begin
    case (ADDR_LO[6:1])
      6'h00:   data_out <= 4'b1110;
      6'h01: 
        case (autoconfig_state)
          Offer_8M: data_out <= 4'b0000;
          Offer_4M: data_out <= 4'b0111;
          Offer_2M: data_out <= 4'b0110;
          Offer_1M: data_out <= 4'b0101;
          default:  data_out <= 4'b0000;
        endcase
      6'h02:   data_out <= ~prod_id[7:4]; // Product number
      6'h03:   data_out <= ~prod_id[3:0]; // Product number
      6'h04:   data_out <= ~4'b1000;
      6'h05:   data_out <= ~4'b0000;
      6'h08:   data_out <= ~mfg_id[15:12]; // Manufacturer ID
      6'h09:   data_out <= ~mfg_id[11:8];  // Manufacturer ID
      6'h0A:   data_out <= ~mfg_id[7:4];   // Manufacturer ID
      6'h0B:   data_out <= ~mfg_id[3:0];   // Manufacturer ID
      6'h10:   data_out <= ~serial[15:12]; // Serial number
      6'h11:   data_out <= ~serial[11:8];  // Serial number
      6'h12:   data_out <= ~serial[7:4];   // Serial number
      6'h13:   data_out <= ~serial[3:0];   // Serial number
      8'h20:   data_out <= 4'b0;
      8'h21:   data_out <= 4'b0;
      default: data_out <= 4'hF;
    endcase
  end
end

always @(negedge UDSn or negedge RESETn)
begin
  if (!RESETn) begin
    configured <= 1'b0;
    shutup <= 1'b0;
    addr_match <= 8'b00000000;
`ifdef Size_4MB
    autoconfig_state <= Offer_4M;
`else
    autoconfig_state <= Offer_8M;
`endif
     end else if (autoconfig_cycle & !ASn & !RWn) begin
    if (ADDR_LO[6:1] == 6'h26) begin
      // We've been told to shut up (not enough memory space)
      // Try offering a smaller block
      if (autoconfig_state >= SHUTUP-1) begin
        // All options exhausted - time to shut up!
        shutup <= 1;
        autoconfig_state <= SHUTUP;
      end else begin
        // Offer the next smallest block
        autoconfig_state <= autoconfig_state + 1;
      end
    end
    else if (ADDR_LO[6:1] == 8'h24) begin
      case (autoconfig_state)
        Offer_8M:
          begin
            addr_match <= 8'hFF;
            shutup <= 1'b1;
          end
        Offer_4M:
          begin
            case(DBUS)
              4'h2:    addr_match <= (addr_match|8'b00001111);
              4'h4:    addr_match <= (addr_match|8'b00111100);
              4'h6:    addr_match <= (addr_match|8'b11110000);
            endcase
            shutup <= 1'b1;
          end
        Offer_2M:
          begin
            case(DBUS)
              4'h2:    addr_match <= (addr_match|8'b00000011);
              4'h4:    addr_match <= (addr_match|8'b00001100);
              4'h6:    addr_match <= (addr_match|8'b00110000);
              4'h8:    addr_match <= (addr_match|8'b11000000);
            endcase
`ifndef Offer_6M
            shutup <= 1'b1;
`else
            autoconfig_state <= Offer_4M;
`endif
          end
        Offer_1M:
          begin
            case(DBUS)
              4'h2:    addr_match <= (addr_match|8'b00000001);
              4'h3:    addr_match <= (addr_match|8'b00000010);
              4'h4:    addr_match <= (addr_match|8'b00000100);
              4'h5:    addr_match <= (addr_match|8'b00001000);
              4'h6:    addr_match <= (addr_match|8'b00010000);
              4'h7:    addr_match <= (addr_match|8'b00100000);
              4'h8:    addr_match <= (addr_match|8'b01000000);
              4'h9:    addr_match <= (addr_match|8'b10000000);
            endcase
            shutup <= 1'b1;
          end
        default:  addr_match <= 8'b0;
      endcase
      configured <= 1'b1;
    end
  end
end
`endif

// Memory controller
`ifndef Size_4MB
assign RAS0n = !((ADDR_HI[22:21] == 2'b01 & access_ras) | (refresh_ras & refresh_cas)); // $200000-3FFFFF
assign RAS1n = !((ADDR_HI[22:21] == 2'b10 & access_ras) | (refresh_ras & refresh_cas)); // $400000-5FFFFF
assign RAS2n = !((ADDR_HI[22:21] == 2'b11 & access_ras) | (refresh_ras & refresh_cas)); // $600000-7FFFFF
assign RAS3n = !((ADDR_HI[22:21] == 2'b00 & access_ras) | (refresh_ras & refresh_cas)); // $800000-9FFFFF
`else
assign RAS0n = 1'b1;
assign RAS1n = 1'b1;
assign RAS2n = !((ADDR_HI[21] == 1'b0 & access_ras) | (refresh_ras & refresh_cas));
assign RAS3n = !((ADDR_HI[21] == 1'b1 & access_ras) | (refresh_ras & refresh_cas));
`endif

assign UCASn = !((access_ucas) | refresh_cas);
assign LCASn = !((access_lcas) | refresh_cas);

// CAS before RAS refresh
// CAS Asserted in S1 & S2
// RAS Asserted in S2
always @(negedge CLK or negedge RESETn)
begin
  if (!RESETn) begin
    refresh_cas <= 1'b0;
  end else begin
    refresh_cas <= (!refresh_cas & ASn & !access_ras);
  end
end

always @(posedge CLK or negedge RESETn)
begin
  if (!RESETn) begin
    refresh_ras <= 1'b0;
  end else begin
    refresh_ras <= refresh_cas;
  end
end

// Memory access
always @(negedge CLK or negedge RESETn)
begin
  if (!RESETn) begin
    ram_cycle = 1'b0;
  end else begin
`ifdef autoconfig
    ram_cycle = (
      ((ADDR_HI[23:20] == 4'h2) & addr_match[0]) |
      ((ADDR_HI[23:20] == 4'h3) & addr_match[1]) |
      ((ADDR_HI[23:20] == 4'h4) & addr_match[2]) |
      ((ADDR_HI[23:20] == 4'h5) & addr_match[3]) |
      ((ADDR_HI[23:20] == 4'h6) & addr_match[4]) |
      ((ADDR_HI[23:20] == 4'h7) & addr_match[5]) |
      ((ADDR_HI[23:20] == 4'h8) & addr_match[6]) |
      ((ADDR_HI[23:20] == 4'h9) & addr_match[7])
      ) & !ASn & configured;
`else
    ram_cycle = ((ADDR_HI[23:20] >= 4'h2) & (ADDR_HI[23:20] <= 4'h9) & !ASn);
`endif
  end
end

always @(posedge CLK or posedge ASn)
begin
  if (ASn) begin
    access_ras  <= 1'b0;
    access_ucas <= 1'b0;
    access_lcas <= 1'b0;
  end else begin
    access_ras  <= (ram_cycle & !access_ucas & !access_lcas); // Assert @ S4, Deassert @ S7
    access_ucas <= (access_ras & !UDSn);                      // Assert @ S6, Deassert @ S7
    access_lcas <= (access_ras & !LDSn);                      // Assert @ S6, Deassert @ S7
  end
end

// Row/Col mux
// Switch to ROW address at falling edge of S0
// Switch to column address at falling edge of S4
always @(negedge CLK)
begin
  mux_switch <= access_ras;
  if (access_ras) begin
    MA0 <= ADDR_HI[19];
    MA1 <= ADDR_HI[20];
  end else begin
    MA0 <= ADDR_LO[1];
    MA1 <= ADDR_LO[2];
  end
end


// R/W Hack because no CPLD pin for R/W
always @(posedge CLK or posedge ASn)
begin
  if (ASn) begin
    RWn <= 1'b1;
  end else begin
    if (!ASn & AS_last) begin
      if (UDSn & LDSn) begin
        RWn <= 1'b0;
      end else begin
        RWn <= 1'b1;
      end
    end
  end
end

always @(posedge CLK) begin
  AS_last <= ASn;
end
endmodule
