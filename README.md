# Lowgo

Get logo images by brand or url.

### Installation

`gem install lowgo`

### Usage

    require 'lowgo'

    Lowgo.logos_for(brand: 'gawker') # =>

    Lowgo.logos_for(url: 'gawker.com') # =>

    Lowgo.logos_for(brand: 'gawker', url: 'gawker.com') # =>