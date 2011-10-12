require File.expand_path('../../spec_helper.rb', __FILE__)

describe Fission::VM do
  before do
    @vm = Fission::VM.new('foo')
    @vm.stub!(:conf_file).and_return(File.join(Fission::VM.path('foo'), 'foo.vmx'))
    @conf_file_path = File.join(Fission::VM.path('foo'), 'foo.vmx')
    @vmrun_cmd = Fission.config['vmrun_cmd']
    @conf_file_response_mock = mock('conf_file_response')
  end

  describe 'new' do
    it 'should set the vm name' do
      Fission::VM.new('foo').name.should == 'foo'
    end
  end

  describe 'start' do
    it 'should start the VM and return a successful response object' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      $?.should_receive(:exitstatus).and_return(0)
      @vm.should_receive(:`).
          with("#{@vmrun_cmd} start #{@conf_file_path.gsub(' ', '\ ')} gui 2>&1").
          and_return("it's all good")

      @vm.start.should be_a_successful_response
    end

    it 'should successfully start the vm headless' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      $?.should_receive(:exitstatus).and_return(0)
      @vm.should_receive(:`).
          with("#{@vmrun_cmd} start #{@conf_file_path.gsub(' ', '\ ')} nogui 2>&1").
          and_return("it's all good")

      @vm.start(:headless => true).should be_a_successful_response
    end

    it 'should return an unsuccessful response if unable to figure out the conf file' do
      @conf_file_response_mock.stub_as_unsuccessful
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)

      @vm.start.should be_an_unsuccessful_response
    end

    it 'should return an unsuccessful response if there was an error starting the VM' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      $?.should_receive(:exitstatus).and_return(1)
      @vm.should_receive(:`).
          with("#{@vmrun_cmd} start #{@conf_file_path.gsub(' ', '\ ')} gui 2>&1").
          and_return("it blew up")

      @vm.start.should be_an_unsuccessful_response
    end
  end

  describe 'stop' do
    it 'should return a successul response object' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      $?.should_receive(:exitstatus).and_return(0)
      @vm.should_receive(:`).
          with("#{@vmrun_cmd} stop #{@conf_file_path.gsub ' ', '\ '} 2>&1").
          and_return("it's all good")

      @vm.stop.should be_a_successful_response
    end

    it 'should return an unsuccessful response if unable to figure out the conf file' do
      @conf_file_response_mock.stub_as_unsuccessful
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)

      @vm.stop.should be_an_unsuccessful_response
    end

    it 'it should return unsuccessful response' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      $?.should_receive(:exitstatus).and_return(1)
      @vm.should_receive(:`).
          with("#{@vmrun_cmd} stop #{@conf_file_path.gsub ' ', '\ '} 2>&1").
          and_return("it blew up")

      @vm.stop.should be_an_unsuccessful_response
    end
  end

  describe 'suspend' do
    it 'should output that it was successful' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      $?.should_receive(:exitstatus).and_return(0)
      @vm.should_receive(:`).
          with("#{@vmrun_cmd} suspend #{@conf_file_path.gsub ' ', '\ '} 2>&1").
          and_return("it's all good")

      @vm.suspend.should be_a_successful_response
    end

    it 'should return an unsuccessful response if unable to figure out the conf file' do
      @conf_file_response_mock.stub_as_unsuccessful
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)

      @vm.suspend.should be_an_unsuccessful_response
    end

    it 'it should output that it was unsuccessful' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      $?.should_receive(:exitstatus).and_return(1)
      @vm.should_receive(:`).
          with("#{@vmrun_cmd} suspend #{@conf_file_path.gsub ' ', '\ '} 2>&1").
          and_return("it blew up")

      @vm.suspend.should be_an_unsuccessful_response
    end
  end

  describe 'snapshots' do
    it 'should return the list of snapshots' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      $?.should_receive(:exitstatus).and_return(0)
      @vm.should_receive(:`).
          with("#{@vmrun_cmd} listSnapshots #{@conf_file_path.gsub ' ', '\ '} 2>&1").
          and_return("Total snapshots: 3\nsnap foo\nsnap bar\nsnap baz\n")

      response = @vm.snapshots
      response.should be_a_successful_response
      response.data.should == ['snap foo', 'snap bar', 'snap baz']
    end

    it 'should return an unsuccessful response if unable to figure out the conf file' do
      @conf_file_response_mock.stub_as_unsuccessful
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)

      @vm.snapshots.should be_an_unsuccessful_response
    end

    it 'should print an error and exit if there was a problem getting the list of snapshots' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      $?.should_receive(:exitstatus).and_return(1)
      @vm.should_receive(:`).
          with("#{@vmrun_cmd} listSnapshots #{@conf_file_path.gsub ' ', '\ '} 2>&1").
          and_return("it blew up")

      @vm.snapshots.should be_an_unsuccessful_response
    end
  end

  describe 'create_snapshot' do
    it 'should create a snapshot' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      $?.should_receive(:exitstatus).and_return(0)
      @vm.should_receive(:`).
          with("#{@vmrun_cmd} snapshot #{@conf_file_path.gsub ' ', '\ '} \"bar\" 2>&1").
          and_return("")

      @vm.create_snapshot('bar').should be_a_successful_response
    end

    it 'should return an unsuccessful response if unable to figure out the conf file' do
      @conf_file_response_mock.stub_as_unsuccessful
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)

      @vm.create_snapshot('bar').should be_an_unsuccessful_response
    end

    it 'should print an error and exit if there was a problem creating the snapshot' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      $?.should_receive(:exitstatus).and_return(1)
      @vm.should_receive(:`).
          with("#{@vmrun_cmd} snapshot #{@conf_file_path.gsub ' ', '\ '} \"bar\" 2>&1").
          and_return("it blew up")

      @vm.create_snapshot('bar').should be_an_unsuccessful_response
    end
  end

  describe 'revert_to_snapshot' do
    it 'should revert to the provided snapshot' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      $?.should_receive(:exitstatus).and_return(0)
      @vm.should_receive(:`).
          with("#{@vmrun_cmd} revertToSnapshot #{@conf_file_path.gsub ' ', '\ '} \"bar\" 2>&1").
          and_return("")

      @vm.revert_to_snapshot('bar').should be_a_successful_response
    end

    it 'should return an unsuccessful response if unable to figure out the conf file' do
      @conf_file_response_mock.stub_as_unsuccessful
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)

      @vm.revert_to_snapshot('bar').should be_an_unsuccessful_response
    end

    it "should print an error and exit if the snapshot doesn't exist" do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      $?.should_receive(:exitstatus).and_return(1)
      @vm.should_receive(:`).
          with("#{@vmrun_cmd} revertToSnapshot #{@conf_file_path.gsub ' ', '\ '} \"bar\" 2>&1").
          and_return("it blew up")

      @vm.revert_to_snapshot('bar').should be_an_unsuccessful_response
    end
  end

  describe 'mac_addresses' do
    before do
      @network_info_mock = mock('network_info')
      @vm.should_receive(:network_info).and_return(@network_info_mock)
    end

    it 'should return a successful response with the list of mac addresses' do
      network_data = { 'ethernet0' => { 'mac_address' => '00:0c:29:1d:6a:64',
                                        'ip_address'  => '127.0.0.1' },
                       'ethernet1' => { 'mac_address' => '00:0c:29:1d:6a:75',
                                        'ip_address'  => '127.0.0.2' } }
      @network_info_mock.stub_as_successful network_data

      response = @vm.mac_addresses

      response.should be_a_successful_response
      response.data.should == ['00:0c:29:1d:6a:64', '00:0c:29:1d:6a:75']
    end

    it 'should return a successful response with an empty list if no mac addresses were found' do
      @network_info_mock.stub_as_successful Hash.new

      response = @vm.mac_addresses

      response.should be_a_successful_response
      response.data.should == []
    end

    it 'should return an unsuccessful response if there was an error getting the mac addresses' do
      @network_info_mock.stub_as_unsuccessful

      response = @vm.mac_addresses

      response.should be_an_unsuccessful_response
      response.data.should be_nil
    end

  end

  describe 'network_info' do
    before do
      @vm.should_receive(:conf_file).and_return(@conf_file_response_mock)
      @conf_file_io = StringIO.new
      @lease_1_response_mock = mock('lease_1_response')
      @lease_2_response_mock = mock('lease_1_response')
    end

    it 'should return a successful response with the list of interfaces, macs, and ips' do
      @conf_file_response_mock.stub_as_successful @conf_file_path

      @lease_1 = Fission::Lease.new :ip_address  => '127.0.0.1',
                                    :mac_address => '00:0c:29:1d:6a:64'
      @lease_1_response_mock.stub_as_successful @lease_1

      @lease_2 = Fission::Lease.new :ip_address  => '127.0.0.2',
                                    :mac_address => '00:0c:29:1d:6a:75'
      @lease_2_response_mock.stub_as_successful @lease_2

      vmx_content = 'ide1:0.deviceType = "cdrom-image"
ethernet0.present = "TRUE"
ethernet1.address = "00:0c:29:1d:6a:75"
ethernet0.connectionType = "nat"
ethernet0.generatedAddress = "00:0c:29:1d:6a:64"
ethernet0.virtualDev = "e1000"
ethernet0.wakeOnPcktRcv = "FALSE"
ethernet0.addressType = "generated"
ethernet0.linkStatePropagation.enable = "TRUE"
ethernet0.generatedAddressenable = "TRUE"
ethernet1.generatedAddressenable = "TRUE"'

      @conf_file_io.string = vmx_content

      File.should_receive(:open).with(@conf_file_path, 'r').
                                 and_yield(@conf_file_io)

      Fission::Lease.should_receive(:find_by_mac_address).
                     with('00:0c:29:1d:6a:64').
                     and_return(@lease_1_response_mock)
      Fission::Lease.should_receive(:find_by_mac_address).
                     with('00:0c:29:1d:6a:75').
                     and_return(@lease_2_response_mock)

      response = @vm.network_info
      response.should be_a_successful_response
      response.data.should == { 'ethernet0' => { 'mac_address'  => '00:0c:29:1d:6a:64',
                                                 'ip_address'   => '127.0.0.1' },
                                'ethernet1' => { 'mac_address'  => '00:0c:29:1d:6a:75',
                                                 'ip_address'   => '127.0.0.2' } }
    end

    it 'should return a successful response with an empty list if there are no macs' do
      @conf_file_response_mock.stub_as_successful @conf_file_path

      vmx_content = 'ide1:0.deviceType = "cdrom-image"
pciBridge7.virtualDev = "pcieRootPort"
pciBridge7.functions = "8"
vmci0.present = "TRUE"
roamingVM.exitBehavior = "go"
tools.syncTime = "TRUE"'

      @conf_file_io.string = vmx_content

      File.should_receive(:open).with(@conf_file_path, 'r').
                                 and_yield(@conf_file_io)

      response = @vm.network_info
      response.should be_a_successful_response
      response.data.should == {}
    end

    it 'should return a successful response without ip addresses if none were found' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @lease_1_response_mock.stub_as_successful nil
      @lease_2_response_mock.stub_as_successful nil

      vmx_content = 'ide1:0.deviceType = "cdrom-image"
ethernet0.present = "TRUE"
ethernet1.address = "00:0c:29:1d:6a:75"
ethernet0.connectionType = "nat"
ethernet0.generatedAddress = "00:0c:29:1d:6a:64"
ethernet0.virtualDev = "e1000"
ethernet0.wakeOnPcktRcv = "FALSE"
ethernet0.addressType = "generated"
ethernet0.linkStatePropagation.enable = "TRUE"
ethernet0.generatedAddressenable = "TRUE"
ethernet1.generatedAddressenable = "TRUE"'

      @conf_file_io.string = vmx_content

      File.should_receive(:open).with(@conf_file_path, 'r').
                                 and_yield(@conf_file_io)

      Fission::Lease.should_receive(:find_by_mac_address).
                     with('00:0c:29:1d:6a:64').
                     and_return(@lease_1_response_mock)
      Fission::Lease.should_receive(:find_by_mac_address).
                     with('00:0c:29:1d:6a:75').
                     and_return(@lease_2_response_mock)

      response = @vm.network_info
      response.should be_a_successful_response
      response.data.should == { 'ethernet0' => { 'mac_address'  => '00:0c:29:1d:6a:64',
                                                 'ip_address'   => nil },
                                'ethernet1' => { 'mac_address'  => '00:0c:29:1d:6a:75',
                                                 'ip_address'   => nil } }
    end

    it 'should return an unsuccessful response with an error if no conf file was found' do
      @conf_file_response_mock.stub_as_unsuccessful

      File.should_not_receive(:open)

      @vm.network_info.should be_an_unsuccessful_response
    end

    it 'should return an unsuccessful response if there was an error getting the ip information' do
      @conf_file_response_mock.stub_as_successful @conf_file_path
      @lease_1_response_mock.stub_as_unsuccessful
      @lease_2_response_mock.stub_as_successful nil

      vmx_content = 'ide1:0.deviceType = "cdrom-image"
ethernet0.present = "TRUE"
ethernet1.address = "00:0c:29:1d:6a:75"
ethernet0.connectionType = "nat"
ethernet0.generatedAddress = "00:0c:29:1d:6a:64"
ethernet0.virtualDev = "e1000"
ethernet0.wakeOnPcktRcv = "FALSE"
ethernet0.addressType = "generated"
ethernet0.linkStatePropagation.enable = "TRUE"
ethernet0.generatedAddressenable = "TRUE"
ethernet1.generatedAddressenable = "TRUE"'

      @conf_file_io.string = vmx_content

      File.should_receive(:open).with(@conf_file_path, 'r').
                                 and_yield(@conf_file_io)

      Fission::Lease.should_receive(:find_by_mac_address).
                     with('00:0c:29:1d:6a:64').
                     and_return(@lease_1_response_mock)
      Fission::Lease.should_receive(:find_by_mac_address).
                     with('00:0c:29:1d:6a:75').
                     and_return(@lease_2_response_mock)

      response = @vm.network_info
      response.should be_an_unsuccessful_response
    end
  end

  describe 'state' do
    before do
      @vm_1 = Fission::VM.new 'foo'
      @vm_2 = Fission::VM.new 'bar'

      @all_running_response_mock = mock('all_running')
      @suspended_response_mock = mock('suspended')

      Fission::VM.stub(:all_running).and_return(@all_running_response_mock)
    end

    it "should return a successful response and 'not running' when the VM is off" do
      @all_running_response_mock.stub_as_successful [@vm_2]

      response = @vm.state
      response.should be_a_successful_response
      response.data.should == 'not running'
    end

    it "should return a successful resopnse and 'running' when the VM is running" do
      @all_running_response_mock.stub_as_successful [@vm_1, @vm_2]

      response = @vm.state
      response.should be_a_successful_response
      response.data.should == 'running'
    end

    it "should return a successful response and 'suspended' when the VM is suspended" do
      @all_running_response_mock.stub_as_successful [@vm_2]
      @suspended_response_mock.stub_as_successful true

      @vm.stub(:suspended?).and_return(@suspended_response_mock)

      response = @vm.state
      response.should be_a_successful_response
      response.data.should == 'suspended'
    end

    it 'should return an unsuccessful response if there was an error getting the running VMs' do
      @all_running_response_mock.stub_as_unsuccessful

      response = @vm.state
      response.should be_an_unsuccessful_response
      response.data.should be_nil
    end

    it 'should return an unsuccessful repsonse if there was an error determining if the VM is suspended' do
      @all_running_response_mock.stub_as_successful [@vm_2]
      @suspended_response_mock.stub_as_unsuccessful

      @vm.stub(:suspended?).and_return(@suspended_response_mock)

      response = @vm.state
      response.should be_an_unsuccessful_response
      response.data.should be_nil
    end
  end

  describe 'suspended?' do
    before do
      FakeFS.activate!
      @vm_root_dir = Fission::VM.path('foo')
      FileUtils.mkdir_p(@vm_root_dir)

      @vm_1 = Fission::VM.new 'foo'
      @vm_2 = Fission::VM.new 'bar'
      @all_running_response_mock = mock('all_running')
    end

    after do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
    end

    describe 'when the vm is not running' do
      it 'should return a successful response and true if a .vmem file exists in the vm dir' do
        FileUtils.touch(File.join(@vm_root_dir, 'foo.vmem'))

        response = @vm.suspended?
        response.should be_a_successful_response
        response.data.should == true
      end

      it 'should return a successful response and false if a .vmem file is not found in the vm dir' do
        response = @vm.suspended?
        response.should be_a_successful_response
        response.data.should == false
      end
    end

    it 'should return a successful response and false if the vm is running' do
      FileUtils.touch(File.join(@vm_root_dir, 'foo.vmem'))

      @all_running_response_mock.stub_as_successful [@vm_1, @vm_2]
      Fission::VM.stub(:all_running).and_return(@all_running_response_mock)

      response = @vm.suspended?
      response.should be_a_successful_response
      response.data.should == false
    end

    it 'should return an unsuccessful repsponse if there is an error getting the list of running vms' do
      @all_running_response_mock.stub_as_unsuccessful
      Fission::VM.stub(:all_running).and_return(@all_running_response_mock)

      response = @vm.suspended?
      response.should be_an_unsuccessful_response
      response.data.should be_nil
    end

  end

  describe 'conf_file' do
    before do
      FakeFS.activate!
      @vm_root_dir = Fission::VM.path('foo')
      FileUtils.mkdir_p(@vm_root_dir)
    end

    after do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
    end

    it 'should return a successful response with the path to the conf file' do
      file_path = File.join(@vm_root_dir, 'foo.vmx')
      FileUtils.touch(file_path)
      response = Fission::VM.new('foo').conf_file
      response.should be_a_successful_response
      response.data.should == file_path
    end

    it 'should return an unsuccessful response with an error if no vmx file was found' do
      response = Fission::VM.new('foo').conf_file
      response.successful?.should == false
      response.output.should match /Unable to find a config file for VM 'foo' \(in '#{File.join(@vm_root_dir, '\*\.vmx')}'\)/m
      response.data.should be_nil
    end

    describe 'when the VM name and conf file name do not match' do
      it 'should return the path to the conf file' do
        file_path = File.join(@vm_root_dir, 'bar.vmx')
        FileUtils.touch(file_path)
        response = Fission::VM.new('foo').conf_file
        response.should be_a_successful_response
        response.data.should == file_path
      end
    end

    describe 'if multiple vmx files are found' do
      it 'should use return a successful response with the conf file which matches the VM name if it exists' do
        ['foo.vmx', 'bar.vmx'].each do |file|
          FileUtils.touch(File.join(@vm_root_dir, file))
        end
        response = Fission::VM.new('foo').conf_file
        response.should be_a_successful_response
        response.data.should == File.join(@vm_root_dir, 'foo.vmx')
      end

      it 'should return an unsuccessful object if none of the conf files matches the VM name' do
        ['bar.vmx', 'baz.vmx'].each do |file|
          FileUtils.touch(File.join(@vm_root_dir, file))
        end
        Fission::VM.new('foo').conf_file
        response = Fission::VM.new('foo').conf_file
        response.successful?.should == false
        error_regex = /Multiple config files found for VM 'foo' \('bar\.vmx', 'baz\.vmx' in '#{@vm_root_dir}'/m
        response.output.should match error_regex
        response.data.should be_nil
      end
    end

  end

  describe "self.all" do
    before do
      @vm_1_mock = mock('vm_1')
      @vm_2_mock = mock('vm_2')
    end

    it "should return a successful object with the list of VM objects" do
      vm_root = Fission.config['vm_dir']
      Dir.should_receive(:[]).
          and_return(["#{File.join vm_root, 'foo.vmwarevm' }", "#{File.join vm_root, 'bar.vmwarevm' }"])

      vm_root = Fission.config['vm_dir']
      File.should_receive(:directory?).with("#{File.join vm_root, 'foo.vmwarevm'}").
                                       and_return(true)
      File.should_receive(:directory?).with("#{File.join vm_root, 'bar.vmwarevm'}").
                                       and_return(true)

      Fission::VM.should_receive(:new).with('foo').and_return(@vm_1_mock)
      Fission::VM.should_receive(:new).with('bar').and_return(@vm_2_mock)

      response = Fission::VM.all
      response.should be_a_successful_response
      response.data.should == [@vm_1_mock, @vm_2_mock]
    end

    it "should return a successful object and not return an item in the list if it isn't a directory" do
      vm_root = Fission.config['vm_dir']
      Dir.should_receive(:[]).
          and_return((['foo', 'bar', 'baz'].map { |i| File.join vm_root, "#{i}.vmwarevm"}))
      File.should_receive(:directory?).
           with("#{File.join vm_root, 'foo.vmwarevm'}").and_return(true)
      File.should_receive(:directory?).
           with("#{File.join vm_root, 'bar.vmwarevm'}").and_return(true)
      File.should_receive(:directory?).
           with("#{File.join vm_root, 'baz.vmwarevm'}").and_return(false)

      Fission::VM.should_receive(:new).with('foo').and_return(@vm_1_mock)
      Fission::VM.should_receive(:new).with('bar').and_return(@vm_2_mock)

      response = Fission::VM.all
      response.should be_a_successful_response
      response.data.should == [@vm_1_mock, @vm_2_mock]
    end

    it "should only query for items with an extension of .vmwarevm" do
      dir_arg = File.join Fission.config['vm_dir'], '*.vmwarevm'
      Dir.should_receive(:[]).with(dir_arg).
                              and_return(['foo.vmwarevm', 'bar.vmwarevm'])
      Fission::VM.all
    end
  end

  describe 'self.all_running' do
    before do
      @vm_1 = Fission::VM.new 'foo'
      @vm_2 = Fission::VM.new 'bar'
      @vm_3 = Fission::VM.new 'baz'
      @vm_names_and_objs = { 'foo' => @vm_1, 'bar' => @vm_2, 'baz' => @vm_3 }
    end

    it 'should return a successful response object with the list of running vms' do
      list_output = "Total running VMs: 2\n/vm/foo.vmwarevm/foo.vmx\n"
      list_output << "/vm/bar.vmwarevm/bar.vmx\n/vm/baz.vmwarevm/baz.vmx\n"

      $?.should_receive(:exitstatus).and_return(0)
      Fission::VM.should_receive(:`).
                  with("#{@vmrun_cmd} list").
                  and_return(list_output)
      [ 'foo', 'bar', 'baz'].each do |vm|
        File.should_receive(:exists?).with("/vm/#{vm}.vmwarevm/#{vm}.vmx").
                                      and_return(true)

        Fission::VM.should_receive(:new).with(vm).
                                         and_return(@vm_names_and_objs[vm])
      end

      response = Fission::VM.all_running
      response.should be_a_successful_response
      response.data.should == [@vm_1, @vm_2, @vm_3]
    end

    it 'should return a successful response object with the VM dir name if it differs from the .vmx file name' do
      vm_dir_file = { 'foo' => 'foo', 'bar' => 'diff', 'baz' => 'baz'}
      list_output = "Total running VMs: 3\n"
      vm_dir_file.each_pair do |dir, file|
        list_output << "/vm/#{dir}.vmwarevm/#{file}.vmx\n"
        File.should_receive(:exists?).with("/vm/#{dir}.vmwarevm/#{file}.vmx").
                                      and_return(true)
        Fission::VM.should_receive(:new).with(dir).
                                         and_return(@vm_names_and_objs[dir])
      end

      $?.should_receive(:exitstatus).and_return(0)
      Fission::VM.should_receive(:`).
                  with("#{@vmrun_cmd} list").
                  and_return(list_output)

      response = Fission::VM.all_running
      response.should be_a_successful_response
      response.data.should == [@vm_1, @vm_2, @vm_3]
    end

    it 'should return an unsuccessful response object if unable to get the list of running vms' do
      $?.should_receive(:exitstatus).and_return(1)
      Fission::VM.should_receive(:`).
                  with("#{@vmrun_cmd} list").
                  and_return("it blew up")
      Fission.stub!(:ui).and_return(Fission::UI.new(@string_io))

      Fission::VM.all_running.should be_an_unsuccessful_response
    end
  end

  describe "self.path" do
    it "should return the path of the vm" do
      vm_path = File.join(Fission.config['vm_dir'], 'foo.vmwarevm').gsub '\\', ''
      Fission::VM.path('foo').should == vm_path
    end
  end

  describe "self.exists?" do
    it "should return true if the vm exists" do
      FakeFS do
        FileUtils.mkdir_p Fission::VM.path('foo')
        response = Fission::VM.exists?('foo')
        response.should be_a_successful_response
        response.data.should == true
      end
    end

    it 'should return false if the vm does not exist' do
      FakeFS do
        FileUtils.rm_r Fission::VM.path('foo')
        response = Fission::VM.exists?('foo')
        response.should be_a_successful_response
        response.data.should == false
      end
    end
  end

  describe "self.clone" do
    before do
      @source_vm = 'foo'
      @target_vm = 'bar'
      @clone_response_mock = mock('clone_response')
      @vm_files = ['.vmx', '.vmxf', '.vmdk', '-s001.vmdk', '-s002.vmdk', '.vmsd']

      FakeFS.activate!

      FileUtils.mkdir_p Fission::VM.path('foo')

      @vm_files.each do |file|
        FileUtils.touch File.join(Fission::VM.path('foo'), "#{@source_vm}#{file}")
      end

      ['.vmx', '.vmxf', '.vmdk'].each do |ext|
        File.open(File.join(Fission::VM.path('foo'), "foo#{ext}"), 'w') { |f| f.write 'foo.vmdk'}
      end

      vmx_content = 'ide1:0.deviceType = "cdrom-image"
nvram = "foo.nvram"
ethernet0.present = "TRUE"
ethernet1.address = "00:0c:29:1d:6a:75"
ethernet0.connectionType = "nat"
ethernet0.generatedAddress = "00:0c:29:1d:6a:64"
ethernet0.virtualDev = "e1000"
tools.remindInstall = "TRUE"
ethernet0.wakeOnPcktRcv = "FALSE"
ethernet0.addressType = "generated"
uuid.action = "keep"
ethernet0.linkStatePropagation.enable = "TRUE"
ethernet0.generatedAddressenable = "TRUE"
ethernet1.generatedAddressenable = "TRUE"'

      File.open(File.join(Fission::VM.path('foo'), "foo.vmx"), 'w') do |f|
        f.write vmx_content
      end

      ['.vmx', '.vmxf'].each do |ext|
        File.should_receive(:binary?).
             with(File.join(Fission::VM.path('bar'), "bar#{ext}")).
             and_return(false)
      end
    end

    after do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
    end

    it 'should copy the vm files to the target' do
      File.should_receive(:binary?).
           with(File.join(Fission::VM.path('bar'), "bar.vmdk")).
           and_return(true)
      Fission::VM.clone @source_vm, @target_vm

      File.directory?(Fission::VM.path('bar')).should == true

      @vm_files.each do |file|
        File.file?(File.join(Fission::VM.path('bar'), "#{@target_vm}#{file}")).should == true
      end
    end

    it "should copy the vm files to the target if a file name doesn't match the directory" do
      FileUtils.touch File.join(Fission::VM.path('foo'), 'other_name.nvram')
      File.should_receive(:binary?).
           with(File.join(Fission::VM.path('bar'), "bar.vmdk")).
           and_return(true)
      Fission::VM.clone @source_vm, @target_vm

      File.directory?(Fission::VM.path('bar')).should == true

      @vm_files.each do |file|
        File.file?(File.join(Fission::VM.path('bar'), "#{@target_vm}#{file}")).should == true
      end

      File.file?(File.join(Fission::VM.path('bar'), "bar.nvram")).should == true
    end

    it "should copy the vm files to the target if a sparse disk file name doesn't match the directory" do
      FileUtils.touch File.join(Fission::VM.path('foo'), 'other_name-s003.vmdk')
      File.should_receive(:binary?).
           with(File.join(Fission::VM.path('bar'), "bar.vmdk")).
           and_return(true)
      Fission::VM.clone @source_vm, @target_vm

      File.directory?(Fission::VM.path('bar')).should == true

      @vm_files.each do |file|
        File.file?(File.join(Fission::VM.path('bar'), "#{@target_vm}#{file}")).should == true
      end

      File.file?(File.join(Fission::VM.path('bar'), "bar-s003.vmdk")).should == true
    end

    it 'should update the target vm config files' do
      File.should_receive(:binary?).
           with(File.join(Fission::VM.path('bar'), "bar.vmdk")).
           and_return(true)
      Fission::VM.clone @source_vm, @target_vm

      ['.vmx', '.vmxf'].each do |ext|
        File.read(File.join(Fission::VM.path('bar'), "bar#{ext}")).should_not match /foo/
        File.read(File.join(Fission::VM.path('bar'), "bar#{ext}")).should match /bar/
      end
    end

    it 'should disable VMware tools warning in the conf file' do
      File.should_receive(:binary?).
           with(File.join(Fission::VM.path('bar'), "bar.vmdk")).
           and_return(true)
      Fission::VM.clone @source_vm, @target_vm

      pattern = /^tools\.remindInstall = "FALSE"/

      File.read(File.join(Fission::VM.path('bar'), "bar.vmx")).should match pattern
    end

    it 'should remove auto generated MAC addresses from the conf file' do
      File.should_receive(:binary?).
           with(File.join(Fission::VM.path('bar'), "bar.vmdk")).
           and_return(true)
      Fission::VM.clone @source_vm, @target_vm

      pattern = /^ethernet\.+generatedAddress.+/

      File.read(File.join(Fission::VM.path('bar'), "bar.vmx")).should_not match pattern
    end

    it 'should setup the conf file to generate a new uuid' do
      File.should_receive(:binary?).
           with(File.join(Fission::VM.path('bar'), "bar.vmdk")).
           and_return(true)
      Fission::VM.clone @source_vm, @target_vm

      pattern = /^uuid\.action = "create"/

      File.read(File.join(Fission::VM.path('bar'), "bar.vmx")).should match pattern
    end

    it "should not try to update the vmdk file if it's not a sparse disk" do
      File.should_receive(:binary?).
           with(File.join(Fission::VM.path('bar'), "bar.vmdk")).and_return(true)
      Fission::VM.clone @source_vm, @target_vm

      File.read(File.join(Fission::VM.path('bar'), 'bar.vmdk')).should match /foo/
    end

    it "should update the vmdk when a sparse disk is found" do
      File.should_receive(:binary?).
           with(File.join(Fission::VM.path('bar'), "bar.vmdk")).and_return(false)
      Fission::VM.clone @source_vm, @target_vm

      File.read(File.join(Fission::VM.path('bar'), 'bar.vmdk')).should match /bar/
    end

    it 'should return a successful response object if clone was successful' do
      File.should_receive(:binary?).
           with(File.join(Fission::VM.path('bar'), "bar.vmdk")).and_return(true)

      Fission::VM.clone(@source_vm, @target_vm).should be_a_successful_response
    end
  end

  describe "delete" do
    before do
      @target_vm = 'foo'
      @vm_files = %w{ .vmx .vmxf .vmdk -s001.vmdk -s002.vmdk .vmsd }
      FakeFS.activate!

      FileUtils.mkdir_p Fission::VM.path(@target_vm)

      @vm_files.each do |file|
        FileUtils.touch File.join(Fission::VM.path(@target_vm), "#{@target_vm}#{file}")
      end
    end

    after do
      FakeFS.deactivate!
    end

    it "should delete the target vm files" do
      Fission::Metadata.stub!(:delete_vm_info)
      Fission::VM.new(@target_vm).delete
      @vm_files.each do |file|
        File.exists?(File.join(Fission::VM.path(@target_vm), "#{@target_vm}#{file}")).should == false
      end
    end

    it 'should delete the target vm metadata' do
      Fission::Metadata.should_receive(:delete_vm_info)
      Fission::VM.new(@target_vm).delete
    end

    it 'should return a successful reponsse object' do
      Fission::Metadata.stub!(:delete_vm_info)
      Fission::VM.new(@target_vm).delete.should be_a_successful_response
    end

  end
end
