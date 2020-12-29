# 旋转NMS
def polynms(dets, thresh):
    scores = dets[:, 8]                         # 读取置信度
    polygon_list = [Polygon(dets[i, :8].reshape(4, 2)).convex_hull
                    for i in range(len(dets))]  # 转换为多边形4点格式
    order = scores.argsort()[::-1]              # 从大到小的下坐标
    keep = []                                   # 拟保留的bbox下坐标
    while order.size > 0:
        i = order[0]
        keep.append(i)
        # 计算其它bbox与当前bbox的相交区域
        inter_list = [polygon_list[i].intersection(
            polygon_list[order[j+1]]).area for j in range(len(order)-1)]
        # 计算其它bbox与当前bbox的相与区域
        union_list = [polygon_list[order[0]].union(
            polygon_list[order[i+1]]).area for i in range(len(order)-1)]
        # IoU的计算
        iou = np.array(inter_list)/np.array(union_list)
        # IoU低于某个阈值，则保留当前的bbox
        inds = np.where(iou <= thresh)[0]
        order = order[inds + 1]   # cause len(iou)==len(order)-1
    return keep


# 旋转NMS加速版
def polynms_fast(dets, thresh):
    obbs = dets[:, 0:-1]
    x1 = np.min(obbs[:, 0::2], axis=1)      # [::] 即 [起始下标：终止下标：间隔距离]
    y1 = np.min(obbs[:, 1::2], axis=1)      # y的最小值
    x2 = np.max(obbs[:, 0::2], axis=1)      # x的最大值
    y2 = np.max(obbs[:, 1::2], axis=1)      # y的最大值
    scores = dets[:, 8]                     # 获取置信度
    areas = (x2 - x1 + 1) * (y2 - y1 + 1)   # 获取每个旋转框对应的水平框的面积
    polys = []                              # 生成多边形4点形式
    for i in range(len(dets)):
        tm_polygon = Polygon(dets[i,:8].reshape(4,2)).convex_hull  # convex_hull凸包操作便于得到轮廓
        polys.append(tm_polygon)            # 旋转框
    order = scores.argsort()[::-1]          # 按照置信度降序排列
    keep = []
    while order.size > 0:
        i = order[0]
        keep.append(i)  # 最高置信度入队
        xx1 = np.maximum(x1[i], x1[order[1:]])   # 逐位比较，返回最大值
        yy1 = np.maximum(y1[i], y1[order[1:]])   # 最左边界
        xx2 = np.minimum(x2[i], x2[order[1:]])   # 最右边界
        yy2 = np.minimum(y2[i], y2[order[1:]])   # 最上边界
        w = np.maximum(0.0, xx2 - xx1)           # 得到每个水平bbox的宽
        h = np.maximum(0.0, yy2 - yy1)           # 得到每个水平bbox的长
        hbb_inter = w * h                        # 求当前bbox与其它bbox的水平相交面积
        hbb_ovr = hbb_inter / (areas[i] + areas[order[1:]] - hbb_inter)   # 水平模型下当前bbox与其它bbox的IoU
        h_inds = np.where(hbb_ovr > 0)[0]        # 将有水平模式下有交集的bbox选出来
        tmp_order = order[h_inds + 1]            # 筛选一部分
        for j in range(tmp_order.size):
            # 计算当前poly[i]与其它poly的交
            inter = polys[i].intersection(polys[tmp_order[j]]).area
            # 计算当前poly[i]与其它poly的并
            union = polys[i].union(polys[tmp_order[j]]).area
            hbb_ovr[h_inds[j]] = inter/union
        inds = np.where(hbb_ovr <= thresh)[0]
        order = order[inds + 1]                  # 需要判断的bbox越来越少
    return keep
