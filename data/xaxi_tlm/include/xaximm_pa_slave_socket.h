#ifndef XAXIMM_PA_SLAVE_SOCKET_H
#define XAXIMM_PA_SLAVE_SOCKET_H
#include "xaxi_tlm.h"
namespace xaxi_tlm{
  class xaximm_wr_pa_slave_socket_imp;
  class xaximm_wr_pa_slave_socket
    :public xaxi_tlm::xaxi_tlm_master_base,
    public sc_module{
    public:
      ~xaximm_wr_pa_slave_socket();
      //Interface configuration
      xaximm_pa_if_config           aximm_config;
      //Interface pins
      xaximm_wr_addr_ch_pa_pins xaximm_wr_addr_skt_pin_if;
      xaximm_wr_data_ch_pa_pins xaximm_wr_data_skt_pin_if;
      xaximm_wr_resp_ch_pa_pins xaximm_wr_resp_skt_pin_if;

      //Initialize configurations and pins
      xaximm_wr_pa_slave_socket(sc_core::sc_module_name p_name,xaximm_pa_if_config& p_aximm_config);

      tlm::tlm_sync_enum
        nb_transport_bw(int socket_id,
            xaxi_tlm_transaction & trans,
            tlm::tlm_phase & phase,
            sc_core::sc_time & t);
      void set_slave_protocol(xaximm_wr_pa_slave_protocol_base* p_xaximm_wr_pa_s_protocol);

      //generate pin accurate signals using attached protocol and queued transactions
      void simulate_single_cycle();

      void bind(xaxi_tlm::xaxi_tlm_slave_socket& slave_socket);
    protected:
    private:
      xaximm_wr_pa_slave_socket_imp *p_imp;
      friend class xaxi_tlm_master_socket;
    };
  class xaximm_rd_pa_slave_socket_imp;
  class xaximm_rd_pa_slave_socket
    :public xaxi_tlm::xaxi_tlm_master_base,
    public sc_module{
    public:
      ~xaximm_rd_pa_slave_socket();
      //Interface configuration
      xaximm_pa_if_config           aximm_config;
      //Interface pins
      xaximm_rd_addr_ch_pa_pins xaximm_rd_addr_skt_pin_if;
      xaximm_rd_data_ch_pa_pins xaximm_rd_data_skt_pin_if;

      //Initialize configurations and pins
      xaximm_rd_pa_slave_socket(sc_core::sc_module_name p_name,xaximm_pa_if_config& p_aximm_config);

      tlm::tlm_sync_enum
        nb_transport_bw(int socket_id,
            xaxi_tlm_transaction & trans,
            tlm::tlm_phase & phase,
            sc_core::sc_time & t);

      void set_slave_protocol(xaximm_rd_pa_slave_protocol_base* p_xaximm_rd_pa_s_protocol);

      //generate pin accurate signals using attached protocol and queued transactions
      void simulate_single_cycle();

      void bind(xaxi_tlm::xaxi_tlm_slave_socket& slave_socket);
    protected:
    private:
      xaximm_rd_pa_slave_socket_imp *p_imp;
      friend class xaxi_tlm_master_socket;
    };
  class xaximm_pa_slave_socket:public sc_module{
  public:
    xaximm_pa_slave_socket(sc_core::sc_module_name p_name,xaximm_pa_if_config& p_aximm_config);
    void set_slave_protocol(
        xaximm_wr_pa_slave_protocol_base* p_xaximm_wr_pa_s_protocol,
        xaximm_rd_pa_slave_protocol_base* p_xaximm_rd_pa_s_protocol
        );
    void bind(xaxi_tlm::xaxi_tlm_slave_socket& p_wr_slave_socket,
        xaxi_tlm::xaxi_tlm_slave_socket& p_rd_slave_socket);
    void simulate_single_cycle();
    xaximm_rd_pa_slave_socket rd_slave_socket;	
    xaximm_wr_pa_slave_socket wr_slave_socket;
  protected:
  private:
  };
}

#endif

// XSIP watermark, do not delete 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689