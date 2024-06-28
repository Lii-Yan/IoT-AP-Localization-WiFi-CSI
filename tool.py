import matplotlib.pyplot as plt
import numpy as np

def plot_cdf(angle_error,title):
    fig, ax = plt.subplots()
    for AP_index in range(10):
        AOA_chazhi=np.sort(np.array(angle_error[AP_index]).flatten())
        cdf = np.cumsum(np.ones_like(AOA_chazhi)) / len(AOA_chazhi)
        ax.plot(AOA_chazhi, cdf, label='AP'+str(AP_index+1))
    # Set the x-axis limits
    ax.set_xlim([0, 20])
    ax.xaxis.set_ticks(np.arange(0, 20+2.5, 2.5))
    ax.xaxis.set_ticklabels([f'{i:.1f}' for i in np.arange(0, 20+2.5, 2.5)])

    # Set the y-axis limits
    ax.set_ylim([0, 1])
    ax.yaxis.set_ticks(np.arange(0, 1.1, 0.1))
    ax.yaxis.set_ticklabels([f'{i:.1f}' for i in np.arange(0, 1.1, 0.1)])

    # Add grid lines
    ax.grid(True)

    # Add a legend
    ax.legend(loc='upper left')
    
    # Add a name
    ax.set_title(title)

    # Show the plot
    plt.show()

# 滑窗获取每个数据
def data_divide(data):
    [x, y, y0, traj_idx]=data
    data=[]
    for traj_i in range(x.shape[-1]):
        temp_x=x[:,:,:,:,traj_i]
        temp_y=y[traj_i+2,:]
        temp_traj_idx=traj_idx[traj_i:traj_i+5]
        data_temp=[temp_x,temp_y, y0,temp_traj_idx]
        data.append(data_temp)
    return data