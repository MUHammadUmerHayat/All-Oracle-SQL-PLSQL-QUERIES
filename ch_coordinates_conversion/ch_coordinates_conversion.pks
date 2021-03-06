create or replace package ch_coordinates_conversion as

-- The MIT License (MIT) -- {
-- 
-- Copyright (c) 2014 Federal Office of Topography swisstopo, Wabern, CH and Joerg Schmidt, Rola AG, Zürich, CH
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
--  of this software and associated documentation files (the "Software"), to deal
--  in the Software without restriction, including without limitation the rights
--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--  copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
--  all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
--   THE SOFTWARE.
--

-- Source: http://www.swisstopo.admin.ch/internet/swisstopo/en/home/topics/survey/sys/refsys/projections.html (see PDFs under "Documentation")
--
-- Translated from python to oracle by Joerg Schmidt (Rola AG)
--
-- Please validate your results with NAVREF on-line service: http://www.swisstopo.admin.ch/internet/swisstopo/en/home/apps/calc/navref.html (difference ~ 1-2m) -- }

   function WGStoCHy(lat in out float, lng in out float) return float;
   function WGStoCHx(lat in out float, lng in out float) return float;
   function CHtoWGSlat(y float, x float) return float;
   function CHtoWGSlng(y float, x float) return float;
   function DECtoSEX(angle float) return float;

-- Convert WGS lat/long (° dec) to CH y

end ch_coordinates_conversion;
/
