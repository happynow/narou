# -*- coding: utf-8 -*-
#
# Copyright 2013 whiteleaf. All rights reserved.
#

require "erb"
require_relative "narou"

class Template
  TEMPLATE_DIR = "template/"

  #
  # テンプレートを元にファイルを作成
  #
  # src_filename  読み込みたいテンプレートファイル名(.erb は省略する)
  # dest_filepath 保存先ファイルパス。ディレクトリならファイル名はsrcと同じ名前で保存する
  # _binding      変数とか設定したいスコープの binding 変数を渡す
  # overwrite     上書きするか
  #
  def self.write(src_filename, dest_filepath, _binding, overwrite = false)
    if File.directory?(dest_filepath)
      dest_filepath = File.join(dest_filepath, src_filename)
    end
    unless overwrite
      return if File.exists?(dest_filepath)
    end
    result = get(src_filename, _binding) or return nil
    File.write(dest_filepath, result)
  end

  #
  # テンプレートを元にデータを作成
  #
  # テンプレートファイルの検索順位
  # 1. root_dir/template
  # 2. script_dir/template
  #
  def self.get(src_filename, _binding, binary_version = 1.0)
    @@binary_version = binary_version
    @@src_filename = src_filename
    [Narou.get_root_dir, Narou.get_script_dir].each do |dir|
      path = File.join(dir, TEMPLATE_DIR, src_filename + ".erb")
      next unless File.exists?(path)
      src = open(path, "r:BOM|UTF-8") { |fp| fp.read }
      result = ERB.new(src, nil, "-").result(_binding)
      return result
    end
    nil
  end

  def self.invalid_templace_version?
    @@src_version < @@binary_version
  end

  #
  # 書かれているテンプレートがどのバージョンのテンプレートを設定
  #
  def self.target_binary_version(version)
    @@src_version = version
    if invalid_templace_version?
      error "テンプレートのバージョンが古いので意図しない動作をする可能性があります\n" +
            "(#{@@src_filename}.erb ver #{version.to_f} < #{@@binary_version.to_f})"
    end
  end
end
