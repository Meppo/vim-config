# vim config 

This is my vim config file and shell script file used to generate cscope/tags file for C projects.


# Installation

1. downlaod all files: vimrc, update.sh

2. backup your origin config file $HOME/.vimrc and vim plugins.

    cp $HOME/.vimrc $HOME/vimrc_bak
    
    mv $HOME/.vim $HOME/vim_bak
    
3. use vimrc to cover your origin config file

    cp vimrc $HOME/.vimrc
    
4. run gvim and use the manager plugin(vundle) to install other plugins we need.

   git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
   
   gvim
   
   :PluginInstall
    
5. create cscope and tags for your C project. buf first , the ctags and cscope are required, you'll need to install them before do this below.

   ./update.sh -a /opt/work/YOUR_PROJECT 
   
   the command will create ctags and cscope files for YOUR_PROJECT at $HOME/vim_tags_dir/ and add this path to the vim config file $HOME/.vimrc, then the vim will find this cscope/tags file automatically when you edit the files of YOUR_PROJECT.
   
6. now edit your project's file and try it.

   cd /the/path/of/YOUR_PROJECT
   
   gvim
   
   :wm
   
   :ctrlp  
   
  choice a file and begin to program...  ^_^
