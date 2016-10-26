using GrowFlow.Api.Compliance.Service;
using GrowFlow.Model;
using GrowFlow.Model.Persistance;
using GrowFlow.Web.Attributes;
using GrowFlow.Web.DTO.Admin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;

namespace GrowFlow.Web.WebAPI
{
    [AuthorizeUserApi]
    public partial class AdminController : GrowFlowApiController
    {
        [HttpGet]
        [Route("Rooms")]
        public List<RoomDTO> GetRooms(int accountId)
        {
            List<RoomDTO> rooms = new List<RoomDTO>();

            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    rooms = service.GetRooms()
                            .Where(r => !string.IsNullOrEmpty(r.Name))
                            .Select(r => new RoomDTO
                            {
                                Id = r.Id,
                                Name = r.Name,
                                Type = r.Stage.ToRoomType(),
                                Notes = r.Notes,
                                IsPlant = r.IsPlant
                            }).ToList();

                    return rooms;
                }
            }
        }

        [HttpPost]
        [Route("Room")]
        public async Task<CreateOperationResult> CreateRoom(CreateRoomDTO dto)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    Site facility = dbContext.Set<Site>().AsNoTracking()
                        .SingleOrDefault(s => s.AccountId == account.Id && s.Type == SiteType.Facility);

                    if (facility == null)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = "Unable to create room.  No facility location exists for this account."
                        };
                    }

                    try
                    {
                        var result = await service.CreateRoomAsync(
                            account,
                            facility,
                            dto.Name,
                            dto.Type,
                            dto.Notes);
                        return new CreateOperationResult()
                        {
                            Success = true,
                            Data = result
                        };
                    }
                    catch (Exception e)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = e.Message
                        };
                    }
                }
            }
        }

        [HttpPut]
        [Route("Room/{roomId:int}")]
        public async Task<CreateOperationResult> EditRoom(int roomId, RoomDTO dto)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    Site facility = dbContext.Set<Site>().AsNoTracking()
                        .SingleOrDefault(s => s.AccountId == account.Id && s.Type == SiteType.Facility);

                    if (facility == null)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = "Unable to edit room.  No facility location exists for this account."
                        };
                    }

                    try
                    {
                        var result =
                            await service.EditRoomAsync(account, facility, roomId, dto.Name, dto.Type, dto.Notes);
                        return new CreateOperationResult()
                        {
                            Success = true,
                            Data = result
                        };
                    }
                    catch (Exception e)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = e.Message
                        };
                    }
                }
            }
        }

        [HttpGet]
        [Route("Room/{roomId:int}/IsDeletable")]
        public DeletableDTO IsRoomDeletable(int roomId)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    bool isDeletable = service.DoesRoomContainInventory(account, roomId);

                    return new DeletableDTO
                    {
                        IsDeletable = isDeletable,
                        Message = "Please remove all inventory from this room before deleting."
                    };
                }
            }
        }

        [HttpDelete]
        [Route("Room/{roomId:int}")]
        public async Task<OperationResult> DeleteRoom(int roomId)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var result = await service.DeleteRoomAsync(account, roomId);
                        return new CreateOperationResult()
                        {
                            Success = result
                        };
                    }
                    catch (Exception e)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = e.Message
                        };
                    }
                }
            }
        }
    }
}