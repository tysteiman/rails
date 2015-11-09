require 'abstract_unit'
require 'pathname'
require 'file_update_checker_with_enumerable_test_cases'

class FileEventedUpdateCheckerTest < ActiveSupport::TestCase
  include FileUpdateCheckerWithEnumerableTestCases

  def new_checker(files=[], dirs={}, &block)
    ActiveSupport::FileEventedUpdateChecker.new(files, dirs, &block)
  end

  def teardown
    super
    Listen.stop
  end

  def wait
    sleep 0.5
  end
end

class FileEventedUpdateCheckerPathHelperTest < ActiveSupport::TestCase
  def pn(path)
    Pathname.new(path)
  end

  setup do
    @ph = ActiveSupport::FileEventedUpdateChecker::PathHelper.new
  end

  test '#xpath returns the expanded path as a Pathname object' do
    assert_equal pn(__FILE__).expand_path, @ph.xpath(__FILE__)
  end

  test '#normalize_extension returns a bare extension as is' do
    assert_equal 'rb', @ph.normalize_extension('rb')
  end

  test '#normalize_extension removes a leading dot' do
    assert_equal 'rb', @ph.normalize_extension('.rb')
  end

  test '#normalize_extension supports symbols' do
    assert_equal 'rb', @ph.normalize_extension(:rb)
  end

  test '#longest_common_subpath finds the longest common subpath, if there is one' do
    paths = %w(
      /foo/bar
      /foo/baz
      /foo/bar/baz/woo/zoo
    ).map {|path| pn(path)}

    assert_equal pn('/foo'), @ph.longest_common_subpath(paths)
  end

  test '#longest_common_subpath returns the root directory as an edge case' do
    paths = %w(
      /foo/bar
      /foo/baz
      /foo/bar/baz/woo/zoo
      /wadus
    ).map {|path| pn(path)}

    assert_equal pn('/'), @ph.longest_common_subpath(paths)
  end

  test '#longest_common_subpath returns nil for an empty collection' do
    assert_nil @ph.longest_common_subpath([])
  end

  test '#existing_parent returns the most specific existing ascendant' do
    wd = Pathname.getwd

    assert_equal wd, @ph.existing_parent(wd)
    assert_equal wd, @ph.existing_parent(wd.join('non-existing/directory'))
    assert_equal pn('/'), @ph.existing_parent(pn('/non-existing/directory'))
  end
end
