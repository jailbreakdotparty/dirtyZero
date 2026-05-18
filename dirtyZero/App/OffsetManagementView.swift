//
//  OffsetManagementView.swift
//  lara
//
//  Created by lunginspector on 5/9/26.
//  skidded this from lara but it's techincally mine so it's chill
//

import SwiftUI
import PartyUI

struct OffsetManagementView: View {
    @EnvironmentObject var mgr: dirtyZeroManager
    @State private var editable: [String: String] = [:]
    @State private var loaded = false
    @State private var lastfocused: String?
    @FocusState private var focusedoff: String?

    private let offsets = [
        "off_inpcb_inp_list_le_next", "off_inpcb_inp_pcbinfo", "off_inpcb_inp_socket",
        "off_inpcbinfo_ipi_zone", "off_inpcb_inp_depend6_inp6_icmp6filt", "off_inpcb_inp_depend6_inp6_chksum",
        "off_socket_so_usecount", "off_socket_so_proto", "off_socket_so_background_thread",
        "off_kalloc_type_view_kt_zv_zv_name",
        "off_thread_t_tro", "off_thread_ro_tro_proc", "off_thread_ro_tro_task",
        "off_thread_machine_upcb", "off_thread_machine_contextdata", "off_thread_ctid",
        "off_thread_options", "off_thread_mutex_lck_mtx_data", "off_thread_machine_kstackptr",
        "off_thread_machine_jop_pid", "off_thread_machine_rop_pid",
        "off_thread_guard_exc_info_code", "off_thread_mach_exc_info_code",
        "off_thread_mach_exc_info_os_reason", "off_thread_mach_exc_info_exception_type",
        "off_thread_ast", "off_thread_task_threads_next",
        "off_proc_p_list_le_next", "off_proc_p_list_le_prev", "off_proc_p_proc_ro",
        "off_proc_p_pid", "off_proc_p_fd", "off_proc_p_flag", "off_proc_p_textvp", "off_proc_p_name",
        "off_proc_ro_pr_task", "off_proc_ro_p_ucred", "off_ucred_cr_label",
        "off_task_itk_space", "off_task_threads_next", "off_task_task_exc_guard", "off_task_map",
        "off_filedesc_fd_ofiles", "off_filedesc_fd_cdir", "off_fileproc_fp_glob",
        "off_fileglob_fg_data", "off_fileglob_fg_flag",
        "off_vnode_v_ncchildren_tqh_first", "off_vnode_v_nclinks_lh_first", "off_vnode_v_parent",
        "off_vnode_v_data", "off_vnode_v_name", "off_vnode_v_usecount", "off_vnode_v_iocount",
        "off_vnode_v_writecount", "off_vnode_v_flag", "off_vnode_v_mount",
        "off_mount_mnt_flag",
        "off_namecache_nc_vp", "off_namecache_nc_child_tqe_next",
        "off_arm_saved_state64_lr", "off_arm_saved_state64_pc", "off_arm_saved_state_uss_ss_64",
        "off_ipc_space_is_table", "off_ipc_entry_ie_object", "off_ipc_port_ip_kobject",
        "off_arm_kernel_saved_state_sp",
        "off_vm_map_hdr", "off_vm_map_header_nentries", "off_vm_map_entry_links_next",
        "off_vm_map_entry_vme_object_or_delta", "off_vm_map_entry_vme_alias",
        "off_vm_map_header_links_next",
        "off_vm_object_vo_un1_vou_size", "off_vm_object_ref_count",
        "off_vm_named_entry_backing_copy", "off_vm_named_entry_size",
        "off_label_l_perpolicy_amfi", "off_label_l_perpolicy_sandbox",
        "sizeof_ipc_entry", "smr_base", "t1sz_boot", "VM_MIN_KERNEL_ADDRESS", "VM_MAX_KERNEL_ADDRESS"
    ]

    var body: some View {
        List {
            Section(
                header: HeaderLabel(text: "Offsets", icon: "tablecells")
            ) {
                ForEach(offsets, id: \.self) { name in
                    HStack {
                        Text(name)
                        Spacer()
                        TextField("0x0", text: Binding(
                            get: { editable[name, default: "0x0"] },
                            set: { editable[name] = $0 }
                        ))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                        .monospaced()
                        .focused($focusedoff, equals: name)
                        .submitLabel(.done)
                        .onSubmit {
                            persistoffs()
                        }
                    }
                }
            }
        }
        .navigationTitle("Offsets")
        .onAppear(perform: initoffs)
        .onChange(of: focusedoff) { current in
            if lastfocused != nil && lastfocused != current {
                persistoffs()
            }
            lastfocused = current
        }
    }

    private func persistoffs() {
        applyoffs()
        savealloffsets()
    }

    private func initoffs() {
        guard !loaded else { return }

        editable = [
            "off_inpcb_inp_list_le_next": hex(off_inpcb_inp_list_le_next),
            "off_inpcb_inp_pcbinfo": hex(off_inpcb_inp_pcbinfo),
            "off_inpcb_inp_socket": hex(off_inpcb_inp_socket),
            "off_inpcbinfo_ipi_zone": hex(off_inpcbinfo_ipi_zone),
            "off_inpcb_inp_depend6_inp6_icmp6filt": hex(off_inpcb_inp_depend6_inp6_icmp6filt),
            "off_inpcb_inp_depend6_inp6_chksum": hex(off_inpcb_inp_depend6_inp6_chksum),
            "off_socket_so_usecount": hex(off_socket_so_usecount),
            "off_socket_so_proto": hex(off_socket_so_proto),
            "off_socket_so_background_thread": hex(off_socket_so_background_thread),
            "off_kalloc_type_view_kt_zv_zv_name": hex(off_kalloc_type_view_kt_zv_zv_name),
            "off_thread_t_tro": hex(off_thread_t_tro),
            "off_thread_ro_tro_proc": hex(off_thread_ro_tro_proc),
            "off_thread_ro_tro_task": hex(off_thread_ro_tro_task),
            "off_thread_machine_upcb": hex(off_thread_machine_upcb),
            "off_thread_machine_contextdata": hex(off_thread_machine_contextdata),
            "off_thread_ctid": hex(off_thread_ctid),
            "off_thread_options": hex(off_thread_options),
            "off_thread_mutex_lck_mtx_data": hex(off_thread_mutex_lck_mtx_data),
            "off_thread_machine_kstackptr": hex(off_thread_machine_kstackptr),
            "off_thread_machine_jop_pid": hex(off_thread_machine_jop_pid),
            "off_thread_machine_rop_pid": hex(off_thread_machine_rop_pid),
            "off_thread_guard_exc_info_code": hex(off_thread_guard_exc_info_code),
            "off_thread_mach_exc_info_code": hex(off_thread_mach_exc_info_code),
            "off_thread_mach_exc_info_os_reason": hex(off_thread_mach_exc_info_os_reason),
            "off_thread_mach_exc_info_exception_type": hex(off_thread_mach_exc_info_exception_type),
            "off_thread_ast": hex(off_thread_ast),
            "off_thread_task_threads_next": hex(off_thread_task_threads_next),
            "off_proc_p_list_le_next": hex(off_proc_p_list_le_next),
            "off_proc_p_list_le_prev": hex(off_proc_p_list_le_prev),
            "off_proc_p_proc_ro": hex(off_proc_p_proc_ro),
            "off_proc_p_pid": hex(off_proc_p_pid),
            "off_proc_p_fd": hex(off_proc_p_fd),
            "off_proc_p_flag": hex(off_proc_p_flag),
            "off_proc_p_textvp": hex(off_proc_p_textvp),
            "off_proc_p_name": hex(off_proc_p_name),
            "off_proc_ro_pr_task": hex(off_proc_ro_pr_task),
            "off_proc_ro_p_ucred": hex(off_proc_ro_p_ucred),
            "off_ucred_cr_label": hex(off_ucred_cr_label),
            "off_task_itk_space": hex(off_task_itk_space),
            "off_task_threads_next": hex(off_task_threads_next),
            "off_task_task_exc_guard": hex(off_task_task_exc_guard),
            "off_task_map": hex(off_task_map),
            "off_filedesc_fd_ofiles": hex(off_filedesc_fd_ofiles),
            "off_filedesc_fd_cdir": hex(off_filedesc_fd_cdir),
            "off_fileproc_fp_glob": hex(off_fileproc_fp_glob),
            "off_fileglob_fg_data": hex(off_fileglob_fg_data),
            "off_fileglob_fg_flag": hex(off_fileglob_fg_flag),
            "off_vnode_v_ncchildren_tqh_first": hex(off_vnode_v_ncchildren_tqh_first),
            "off_vnode_v_nclinks_lh_first": hex(off_vnode_v_nclinks_lh_first),
            "off_vnode_v_parent": hex(off_vnode_v_parent),
            "off_vnode_v_data": hex(off_vnode_v_data),
            "off_vnode_v_name": hex(off_vnode_v_name),
            "off_vnode_v_usecount": hex(off_vnode_v_usecount),
            "off_vnode_v_iocount": hex(off_vnode_v_iocount),
            "off_vnode_v_writecount": hex(off_vnode_v_writecount),
            "off_vnode_v_flag": hex(off_vnode_v_flag),
            "off_vnode_v_mount": hex(off_vnode_v_mount),
            "off_mount_mnt_flag": hex(off_mount_mnt_flag),
            "off_namecache_nc_vp": hex(off_namecache_nc_vp),
            "off_namecache_nc_child_tqe_next": hex(off_namecache_nc_child_tqe_next),
            "off_arm_saved_state64_lr": hex(off_arm_saved_state64_lr),
            "off_arm_saved_state64_pc": hex(off_arm_saved_state64_pc),
            "off_arm_saved_state_uss_ss_64": hex(off_arm_saved_state_uss_ss_64),
            "off_ipc_space_is_table": hex(off_ipc_space_is_table),
            "off_ipc_entry_ie_object": hex(off_ipc_entry_ie_object),
            "off_ipc_port_ip_kobject": hex(off_ipc_port_ip_kobject),
            "off_arm_kernel_saved_state_sp": hex(off_arm_kernel_saved_state_sp),
            "off_vm_map_hdr": hex(off_vm_map_hdr),
            "off_vm_map_header_nentries": hex(off_vm_map_header_nentries),
            "off_vm_map_entry_links_next": hex(off_vm_map_entry_links_next),
            "off_vm_map_entry_vme_object_or_delta": hex(off_vm_map_entry_vme_object_or_delta),
            "off_vm_map_entry_vme_alias": hex(off_vm_map_entry_vme_alias),
            "off_vm_map_header_links_next": hex(off_vm_map_header_links_next),
            "off_vm_object_vo_un1_vou_size": hex(off_vm_object_vo_un1_vou_size),
            "off_vm_object_ref_count": hex(off_vm_object_ref_count),
            "off_vm_named_entry_backing_copy": hex(off_vm_named_entry_backing_copy),
            "off_vm_named_entry_size": hex(off_vm_named_entry_size),
            "off_label_l_perpolicy_amfi": hex(off_label_l_perpolicy_amfi),
            "off_label_l_perpolicy_sandbox": hex(off_label_l_perpolicy_sandbox),
            "sizeof_ipc_entry": hex(sizeof_ipc_entry),
            "smr_base": hex(smr_base),
            "t1sz_boot": hex(t1sz_boot),
            "VM_MIN_KERNEL_ADDRESS": hex(VM_MIN_KERNEL_ADDRESS),
            "VM_MAX_KERNEL_ADDRESS": hex(VM_MAX_KERNEL_ADDRESS)
        ]
        
        loaded = true
    }

    private func applyoffs() {
        func hexparse(_ raw: String) -> String {
            raw
                .replacingOccurrences(of: "0x", with: "")
                .replacingOccurrences(of: "0X", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        func setoffs32(_ key: String, _ setter: (UInt32) -> Void) {
            guard let raw = editable[key] else { return }
            if let value = UInt32(hexparse(raw), radix: 16) {
                setter(value)
            }
        }

        func setoffs64(_ key: String, _ setter: (UInt64) -> Void) {
            guard let raw = editable[key] else { return }
            if let value = UInt64(hexparse(raw), radix: 16) {
                setter(value)
            }
        }

        setoffs32("off_inpcb_inp_list_le_next") { off_inpcb_inp_list_le_next = $0 }
        setoffs32("off_inpcb_inp_pcbinfo") { off_inpcb_inp_pcbinfo = $0 }
        setoffs32("off_inpcb_inp_socket") { off_inpcb_inp_socket = $0 }
        setoffs32("off_inpcbinfo_ipi_zone") { off_inpcbinfo_ipi_zone = $0 }
        setoffs32("off_inpcb_inp_depend6_inp6_icmp6filt") { off_inpcb_inp_depend6_inp6_icmp6filt = $0 }
        setoffs32("off_inpcb_inp_depend6_inp6_chksum") { off_inpcb_inp_depend6_inp6_chksum = $0 }
        setoffs32("off_socket_so_usecount") { off_socket_so_usecount = $0 }
        setoffs32("off_socket_so_proto") { off_socket_so_proto = $0 }
        setoffs32("off_socket_so_background_thread") { off_socket_so_background_thread = $0 }
        setoffs32("off_kalloc_type_view_kt_zv_zv_name") { off_kalloc_type_view_kt_zv_zv_name = $0 }
        setoffs32("off_thread_t_tro") { off_thread_t_tro = $0 }
        setoffs32("off_thread_ro_tro_proc") { off_thread_ro_tro_proc = $0 }
        setoffs32("off_thread_ro_tro_task") { off_thread_ro_tro_task = $0 }
        setoffs32("off_thread_machine_upcb") { off_thread_machine_upcb = $0 }
        setoffs32("off_thread_machine_contextdata") { off_thread_machine_contextdata = $0 }
        setoffs32("off_thread_ctid") { off_thread_ctid = $0 }
        setoffs32("off_thread_options") { off_thread_options = $0 }
        setoffs32("off_thread_mutex_lck_mtx_data") { off_thread_mutex_lck_mtx_data = $0 }
        setoffs32("off_thread_machine_kstackptr") { off_thread_machine_kstackptr = $0 }
        setoffs32("off_thread_machine_jop_pid") { off_thread_machine_jop_pid = $0 }
        setoffs32("off_thread_machine_rop_pid") { off_thread_machine_rop_pid = $0 }
        setoffs32("off_thread_guard_exc_info_code") { off_thread_guard_exc_info_code = $0 }
        setoffs32("off_thread_mach_exc_info_code") { off_thread_mach_exc_info_code = $0 }
        setoffs32("off_thread_mach_exc_info_os_reason") { off_thread_mach_exc_info_os_reason = $0 }
        setoffs32("off_thread_mach_exc_info_exception_type") { off_thread_mach_exc_info_exception_type = $0 }
        setoffs32("off_thread_ast") { off_thread_ast = $0 }
        setoffs32("off_thread_task_threads_next") { off_thread_task_threads_next = $0 }
        setoffs32("off_proc_p_list_le_next") { off_proc_p_list_le_next = $0 }
        setoffs32("off_proc_p_list_le_prev") { off_proc_p_list_le_prev = $0 }
        setoffs32("off_proc_p_proc_ro") { off_proc_p_proc_ro = $0 }
        setoffs32("off_proc_p_pid") { off_proc_p_pid = $0 }
        setoffs32("off_proc_p_fd") { off_proc_p_fd = $0 }
        setoffs32("off_proc_p_flag") { off_proc_p_flag = $0 }
        setoffs32("off_proc_p_textvp") { off_proc_p_textvp = $0 }
        setoffs32("off_proc_p_name") { off_proc_p_name = $0 }
        setoffs32("off_proc_ro_pr_task") { off_proc_ro_pr_task = $0 }
        setoffs32("off_proc_ro_p_ucred") { off_proc_ro_p_ucred = $0 }
        setoffs32("off_ucred_cr_label") { off_ucred_cr_label = $0 }
        setoffs32("off_task_itk_space") { off_task_itk_space = $0 }
        setoffs32("off_task_threads_next") { off_task_threads_next = $0 }
        setoffs32("off_task_task_exc_guard") { off_task_task_exc_guard = $0 }
        setoffs32("off_task_map") { off_task_map = $0 }
        setoffs32("off_filedesc_fd_ofiles") { off_filedesc_fd_ofiles = $0 }
        setoffs32("off_filedesc_fd_cdir") { off_filedesc_fd_cdir = $0 }
        setoffs32("off_fileproc_fp_glob") { off_fileproc_fp_glob = $0 }
        setoffs32("off_fileglob_fg_data") { off_fileglob_fg_data = $0 }
        setoffs32("off_fileglob_fg_flag") { off_fileglob_fg_flag = $0 }
        setoffs32("off_vnode_v_ncchildren_tqh_first") { off_vnode_v_ncchildren_tqh_first = $0 }
        setoffs32("off_vnode_v_nclinks_lh_first") { off_vnode_v_nclinks_lh_first = $0 }
        setoffs32("off_vnode_v_parent") { off_vnode_v_parent = $0 }
        setoffs32("off_vnode_v_data") { off_vnode_v_data = $0 }
        setoffs32("off_vnode_v_name") { off_vnode_v_name = $0 }
        setoffs32("off_vnode_v_usecount") { off_vnode_v_usecount = $0 }
        setoffs32("off_vnode_v_iocount") { off_vnode_v_iocount = $0 }
        setoffs32("off_vnode_v_writecount") { off_vnode_v_writecount = $0 }
        setoffs32("off_vnode_v_flag") { off_vnode_v_flag = $0 }
        setoffs32("off_vnode_v_mount") { off_vnode_v_mount = $0 }
        setoffs32("off_mount_mnt_flag") { off_mount_mnt_flag = $0 }
        setoffs32("off_namecache_nc_vp") { off_namecache_nc_vp = $0 }
        setoffs32("off_namecache_nc_child_tqe_next") { off_namecache_nc_child_tqe_next = $0 }
        setoffs32("off_arm_saved_state64_lr") { off_arm_saved_state64_lr = $0 }
        setoffs32("off_arm_saved_state64_pc") { off_arm_saved_state64_pc = $0 }
        setoffs32("off_arm_saved_state_uss_ss_64") { off_arm_saved_state_uss_ss_64 = $0 }
        setoffs32("off_ipc_space_is_table") { off_ipc_space_is_table = $0 }
        setoffs32("off_ipc_entry_ie_object") { off_ipc_entry_ie_object = $0 }
        setoffs32("off_ipc_port_ip_kobject") { off_ipc_port_ip_kobject = $0 }
        setoffs32("off_arm_kernel_saved_state_sp") { off_arm_kernel_saved_state_sp = $0 }
        setoffs32("off_vm_map_hdr") { off_vm_map_hdr = $0 }
        setoffs32("off_vm_map_header_nentries") { off_vm_map_header_nentries = $0 }
        setoffs32("off_vm_map_entry_links_next") { off_vm_map_entry_links_next = $0 }
        setoffs32("off_vm_map_entry_vme_object_or_delta") { off_vm_map_entry_vme_object_or_delta = $0 }
        setoffs32("off_vm_map_entry_vme_alias") { off_vm_map_entry_vme_alias = $0 }
        setoffs32("off_vm_map_header_links_next") { off_vm_map_header_links_next = $0 }
        setoffs32("off_vm_object_vo_un1_vou_size") { off_vm_object_vo_un1_vou_size = $0 }
        setoffs32("off_vm_object_ref_count") { off_vm_object_ref_count = $0 }
        setoffs32("off_vm_named_entry_backing_copy") { off_vm_named_entry_backing_copy = $0 }
        setoffs32("off_vm_named_entry_size") { off_vm_named_entry_size = $0 }
        setoffs32("off_label_l_perpolicy_amfi") { off_label_l_perpolicy_amfi = $0 }
        setoffs32("off_label_l_perpolicy_sandbox") { off_label_l_perpolicy_sandbox = $0 }
        setoffs32("sizeof_ipc_entry") { sizeof_ipc_entry = $0 }

        setoffs64("smr_base") { smr_base = $0 }
        setoffs64("t1sz_boot") { t1sz_boot = $0 }
        setoffs64("VM_MIN_KERNEL_ADDRESS") { VM_MIN_KERNEL_ADDRESS = $0 }
        setoffs64("VM_MAX_KERNEL_ADDRESS") { VM_MAX_KERNEL_ADDRESS = $0 }

        if t1sz_boot > 0 && t1sz_boot < 64 {
            pac_mask = ~(((1 as UInt64) << (64 - t1sz_boot)) - 1)
        }
    }
}

func hex(_ value: UInt64) -> String {
    "0x" + String(value, radix: 16, uppercase: true)
}

func hex(_ value: UInt32) -> String {
    hex(UInt64(value))
}
