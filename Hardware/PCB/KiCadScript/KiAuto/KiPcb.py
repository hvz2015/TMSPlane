import pcbnew

## Class operating on an already established board
#
class KiPcbOp(object):
    ## @param[in] board Already open and established board object.
    def __init__(self, board):
        self._board = board
        self._io = pcbnew.PCB_IO()
        self.layerI = {pcbnew.BOARD_GetStandardLayerName(n):n for n in range(pcbnew.LAYER_ID_COUNT)}
        self.layerN = {s:n for n, s in self.layerI.iteritems()}
        # generate a LUT with shape integers to a string
        self.padShapes = {
            pcbnew.PAD_SHAPE_CIRCLE: "PAD_SHAPE_CIRCLE",
            pcbnew.PAD_SHAPE_OVAL: "PAD_SHAPE_OVAL",
            pcbnew.PAD_SHAPE_RECT: "PAD_SHAPE_RECT",
            pcbnew.PAD_SHAPE_TRAPEZOID: "PAD_SHAPE_TRAPEZOID"
        }
        if hasattr(pcbnew, 'PAD_SHAPE_ROUNDRECT'):
            self.padShapes[pcbnew.PAD_SHAPE_ROUNDRECT] = "PAD_SHAPE_ROUNDRECT"
        # returns a dictionary netcode:netinfo_item
        self.netCodes = self._board.GetNetsByNetcode()

    ## called by __init__()
    def compute_layer_table(self):
        self.layerTable = {}
        for i in range(pcbnew.LAYER_ID_COUNT):
            self.layerTable[i] = self._board.GetLayerName(i)
        return self.layerTable

    def layer_id_to_name(self, id):
        return self.layerN[id]

    def layer_name_to_id(self, name):
        return self.layerI[name]

    def print_list_of_nets(self):
        for netcode, net in self.netCodes.items():
            print("netcode: {}, name: {}".format(netcode, net.GetNetname()))

    def get_board_boundary(self):
        rect = None
        for d in self._board.GetDrawings():
            if (d.GetLayerName() != "Edge.Cuts"):
                continue
            if (rect == None):
                rect = d.GetBoundingBox()
            else:
                rect.Merge(d.GetBoundingBox())
        return [pcbnew.wxPoint(rect.Centre().x-rect.GetWidth()/2, rect.Centre().y-rect.GetHeight()/2),
                pcbnew.wxPoint(rect.Centre().x-rect.GetWidth()/2, rect.Centre().y+rect.GetHeight()/2),
                pcbnew.wxPoint(rect.Centre().x+rect.GetWidth()/2, rect.Centre().y+rect.GetHeight()/2),
                pcbnew.wxPoint(rect.Centre().x+rect.GetWidth()/2, rect.Centre().y-rect.GetHeight()/2)]

    ## @param[in] layerId consult layerTable, usually 0: F.Cu, 31: B.Cu
    def place_footprint(self, lib, name, ref="", loc=(0,0), layerId=0):
        mod = self._io.FootprintLoad(lib, name)
        if type(loc) == tuple or type(loc) == list:
            p = pcbnew.wxPoint(loc[0], loc[1])
        mod.SetPosition(p)
        mod.SetLayer(layerId)
        mod.SetReference(ref)
        self._board.Add(mod)

    def set_footprint_nets(self, ref="", pinNet={1:'/VDD', 2:'/GND'}):
        mod = self._board.FindModuleByReference(ref)
        if mod == None:
            return None
        for p in mod.Pads():
            netname = pinNet[int(p.GetPadName())]
            netcode = self._board.GetNetcodeFromNetname(netname)
            print netname, netcode
            p.SetNetCode(netcode)
        return True

    def get_fp_pad_pos_netname(self, ref):
        mod = self._board.FindModuleByReference(ref)
        if mod == None:
            return None
        ppn = {}
        for p in mod.Pads():
            ppn[int(p.GetPadName())] = (p.GetCenter(), p.GetNetname())
        return ppn

    def add_track(self, posList=[[0,0], [1,1]], width=None, layerId=0, netName="/GND"):
        netcode = self._board.GetNetcodeFromNetname(netName)
        for i in xrange(len(posList)-1):
            t = posList[i]
            p1 = pcbnew.wxPoint(t[0], t[1]) if type(t) == tuple or type(t) == list else t
            t = posList[i+1]
            p2 = pcbnew.wxPoint(t[0], t[1]) if type(t) == tuple or type(t) == list else t
            if width == None:
                width = self._board.GetDesignSettings().GetCurrentTrackWidth()
            track = pcbnew.TRACK(self._board)
            track.SetStart(p1)
            track.SetEnd(p2)
            track.SetWidth(width)
            track.SetLayer(layerId)
            self._board.Add(track)
            track.SetNetCode(netcode)

    def add_via(self, pos=[0,0], layerIdPair=(0, 31), netName="/GND", size=None, drill=None, vType=pcbnew.VIA_THROUGH):
        netcode = self._board.GetNetcodeFromNetname(netName)
        if size == None:
            size = self._board.GetDesignSettings().GetCurrentViaSize()
        if drill == None:
            drill = self._board.GetDesignSettings().GetCurrentViaDrill()
        if vType == pcbnew.VIA_THROUGH:
            via = pcbnew.VIA(self._board)
            via.SetWidth(size)
            p1 = pcbnew.wxPoint(pos[0], pos[1]) if type(pos) == tuple or type(pos) == list else pos
            via.SetStart(p1)
            via.SetEnd(p1)
            via.SetLayerPair(layerIdPair[0], layerIdPair[1])
            via.SetDrill(drill)
            via.SetViaType(pcbnew.VIA_THROUGH)
            self._board.Add(via)
            via.SetNetCode(netcode)

    def add_zone(self, corners=None, layerId=0, netName="/GND"):
        netcode = self._board.GetNetcodeFromNetname(netName)
        area = self._board.InsertArea(netcode, 0, layerId, corners[0][0], corners[0][1],
                                      pcbnew.CPolyLine.DIAGONAL_EDGE)
        for p in corners[1:]:
            pw = pcbnew.wxPoint(p[0], p[1]) if type(p) == tuple or type(p) == list else p
            area.AppendCorner(pw)
        area.Hatch()